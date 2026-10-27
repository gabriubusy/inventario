import 'package:flutter/foundation.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/proveedores/application/estado_proveedores.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
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
  });

  final RepositorioProveedores _repositorio;
  final ControladorExistencias _existencias;

  /// Other records that store the supplier by name, like incidents.
  final List<RenombrarProveedor> _alRenombrar;
  EstadoProveedores _estado = const CargandoProveedores();
  String _busqueda = '';
  String? _elegidoId;

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
    final resultado = await _repositorio.actualizar(anterior.id, datos);
    if (resultado case ProveedorGuardado(:final proveedor)) {
      _estado = ProveedoresCargados([
        for (final p in _todos) p.id == proveedor.id ? proveedor : p,
      ]);
      notifyListeners();
      if (anterior.nombre != proveedor.nombre) {
        await _existencias.renombrarProveedor(
          anterior.nombre,
          proveedor.nombre,
        );
        for (final renombrar in _alRenombrar) {
          await renombrar(anterior.nombre, proveedor.nombre);
        }
      }
    }
    return resultado;
  }
}
