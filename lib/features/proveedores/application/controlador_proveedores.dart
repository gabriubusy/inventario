import 'package:flutter/foundation.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/proveedores/application/estado_proveedores.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/quitar_marca.dart';
import 'package:inventario/features/proveedores/domain/repositorio_proveedores.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

typedef RenombrarProveedor = Future<void> Function(
  String anterior,
  String nuevo,
);

/// Suppliers list, search and selection. Brands and products come from
/// the stock, so screens should also listen to [ControladorExistencias].
class ControladorProveedores extends ChangeNotifier {
  ControladorProveedores(
    this._repositorio,
    this._existencias, {
    this._alRenombrar = const [],
    this._transacciones = const SinTransaccion(),
  });

  final RepositorioProveedores _repositorio;
  final ControladorExistencias _existencias;

  /// A rename reaches every record or none of them.
  final Transacciones _transacciones;

  /// Other records that store the supplier by name, like incidents.
  final List<RenombrarProveedor> _alRenombrar;
  EstadoProveedores _estado = const CargandoProveedores();
  String _busqueda = '';
  String? _elegidoId;

  /// Products that lost a brand lot, kept for Deshacer.
  List<CambioMarca>? _ultimoQuitado;

  EstadoProveedores get estado => _estado;
  String get busqueda => _busqueda;

  List<Proveedor> get _todos => switch (_estado) {
    CargandoProveedores() => const [],
    ProveedoresCargados(:final proveedores) => proveedores,
  };

  /// Every supplier name, ignoring the search; for suggestions elsewhere.
  List<String> get nombres => [for (final p in _todos) p.nombre];

  /// Matching suppliers, sorted by name.
  List<Proveedor> get visibles {
    final productos = _existencias.productos;
    return [
      for (final proveedor in _todos)
        if (coincideProveedor(
          proveedor,
          suministrosDe(proveedor, productos),
          _busqueda,
        ))
          proveedor,
    ]..sort(
      (a, b) =>
          normalizarParaBusqueda(a.nombre)
              .compareTo(normalizarParaBusqueda(b.nombre)),
    );
  }

  /// The chosen supplier, or the first visible one.
  Proveedor? get elegido {
    final lista = visibles;
    if (lista.isEmpty) return null;
    return lista.firstWhere(
      (p) => p.id == _elegidoId,
      orElse: () => lista.first,
    );
  }

  List<Suministro> suministros(Proveedor proveedor) =>
      suministrosDe(proveedor, _existencias.productos);

  Future<void> cargar() async {
    _estado = ProveedoresCargados(await _repositorio.obtenerTodos());
    notifyListeners();
  }

  void buscar(String texto) {
    if (texto == _busqueda) return;
    _busqueda = texto;
    notifyListeners();
  }

  void elegir(String id) {
    if (id == _elegidoId) return;
    _elegidoId = id;
    notifyListeners();
  }

  /// Moves the selection up (negative) or down, stopping at the ends.
  void moverEleccion(int pasos) {
    final lista = visibles;
    final actual = elegido;
    if (actual == null) return;
    final destino = (lista.indexOf(actual) + pasos).clamp(0, lista.length - 1);
    elegir(lista[destino].id);
  }

  Future<ResultadoGuardarProveedor> crear(DatosProveedor datos) async {
    final resultado = await _repositorio.crear(datos);
    if (resultado case ProveedorGuardado(:final proveedor)) {
      _estado = ProveedoresCargados([..._todos, proveedor]);
      _elegidoId = proveedor.id;
      notifyListeners();
    }
    return resultado;
  }

  /// A new name is carried over to the brand lots that use the old one.
  Future<ResultadoGuardarProveedor> actualizar(
    Proveedor anterior,
    DatosProveedor datos,
  ) async {
    final resultado = await _transacciones.enUna(() async {
      final resultado = await _repositorio.actualizar(anterior.id, datos);
      if (resultado case ProveedorGuardado(:final proveedor)
          when anterior.nombre != proveedor.nombre) {
        await _existencias.renombrarProveedor(
          anterior.nombre,
          proveedor.nombre,
        );
        for (final renombrar in _alRenombrar) {
          await renombrar(anterior.nombre, proveedor.nombre);
        }
      }
      return resultado;
    });
    if (resultado case ProveedorGuardado(:final proveedor)) {
      _estado = ProveedoresCargados([
        for (final p in _todos) p.id == proveedor.id ? proveedor : p,
      ]);
      notifyListeners();
    }
    return resultado;
  }

  /// Takes [marca] off every product of [proveedor]; how many products
  /// lost it, 0 when none had it or it still has stock.
  Future<int> quitarMarca(String proveedor, String marca) async {
    if (!marcaSinExistencias(
      _existencias.productos,
      proveedor: proveedor,
      marca: marca,
    )) {
      return 0;
    }
    final cambios = productosSinMarca(
      _existencias.productos,
      proveedor: proveedor,
      marca: marca,
    );
    if (cambios.isEmpty) return 0;
    final guardados = await _transacciones.enUna(() async {
      final guardados = <CambioMarca>[];
      for (final cambio in cambios) {
        await _existencias.actualizarProducto(
          cambio.antes.id,
          DatosProducto.desde(cambio.despues),
        );
        if (_producto(cambio.antes.id) case final actual?) {
          guardados.add((antes: cambio.antes, despues: actual));
        }
      }
      return guardados;
    });
    _ultimoQuitado = guardados;
    return guardados.length;
  }

  /// False when one of those products changed since, so the brand stays off.
  Future<bool> deshacerQuitarMarca() async {
    final ultimo = _ultimoQuitado;
    _ultimoQuitado = null;
    if (ultimo == null || ultimo.isEmpty) return false;
    if (ultimo.any((c) => _producto(c.antes.id) != c.despues)) return false;
    await _transacciones.enUna(() async {
      for (final cambio in ultimo) {
        await _existencias.actualizarProducto(
          cambio.antes.id,
          DatosProducto.desde(cambio.antes),
        );
      }
    });
    return true;
  }

  Producto? _producto(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
