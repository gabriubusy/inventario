import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/repositorio_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/resultado_devolucion_proveedor.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';

typedef _Cambio = ({
  DevolucionProveedor devolucion,
  List<({Producto antes, Producto despues})> productos,
  List<Movimiento> anotados,
  Incidencia? incidencia,
});

/// Goods sent back to suppliers (Ctrl+D): out of the stock, and made up for
/// by a discount on an invoice, money into the till or the goods again.
class ControladorDevolucionesProveedor extends ChangeNotifier {
  ControladorDevolucionesProveedor(
    this._repositorio,
    this._existencias,
    this._compras, {
    this._movimientos,
    this._incidencias,
    this._transacciones = const SinTransaccion(),
    this._ahora = DateTime.now,
  });

  final RepositorioDevolucionesProveedor _repositorio;
  final ControladorExistencias _existencias;

  /// Discounts lower what its invoices owe.
  final ControladorCompras _compras;
  final ControladorMovimientos? _movimientos;

  /// A return made from an incident answers it as "Se devolvió".
  final ControladorIncidencias? _incidencias;
  final Transacciones _transacciones;
  final DateTime Function() _ahora;
  List<DevolucionProveedor> _todas = const [];
  _Cambio? _ultima;

  DateTime get hoy => _ahora();
  int? get tasaDeHoy => _compras.tasaDeHoy;

  /// Newest first.
  List<DevolucionProveedor> get todas => _todas;

  /// The supplier's invoices still owed, oldest first: the first one is
  /// where a discount goes unless another is chosen.
  List<CuentaPorPagar> cuentasCon(String proveedor) {
    final clave = normalizarParaBusqueda(proveedor);
    return [
      for (final c in _compras.cuentas)
        if (c.debe > 0 && normalizarParaBusqueda(c.compra.proveedor) == clave)
          c,
    ]..sort((a, b) => a.compra.fecha.compareTo(b.compra.fecha));
  }

  /// The invoice number a discount went to; null when it is gone.
  String? facturaDe(String? compraId) {
    for (final compra in _compras.compras) {
      if (compra.id == compraId) return compra.factura;
    }
    return null;
  }

  Future<void> cargar() async => _poner(await _repositorio.obtenerTodas());

  /// Takes the goods out of stock (unless [incidencia] already did), notes
  /// them in the kardex and stores the return, all or nothing.
  Future<ResultadoDevolucionProveedor> registrar({
    required String proveedor,
    required MotivoDevolucion motivo,
    required List<LineaCompra> lineas,
    required Compensacion compensacion,
    String? compraId,
    MedioPago medio = MedioPago.efectivoDolares,
    String nota = '',
    Incidencia? incidencia,
  }) async {
    final sacar = !(incidencia?.sacada ?? false);
    final datos = DevolucionProveedor(
      fecha: _ahora(),
      proveedor: proveedor,
      motivo: motivo,
      lineas: lineas,
      compensacion: compensacion,
      nota: nota,
      incidenciaId: incidencia?.id,
      sacada: sacar,
    );
    if (sacar) {
      for (final linea in _juntarPorLote(lineas)) {
        final producto = _buscar(linea.productoId);
        if (producto == null ||
            sacarDeLote(
                  producto,
                  marca: linea.marca,
                  proveedor: proveedor,
                  piezas: linea.piezas,
                  cantidad: linea.cantidad,
                ) ==
                null) {
          return DevolucionNoAlcanza(linea.producto);
        }
      }
    }
    final DevolucionProveedor completa;
    switch (compensacion) {
      case Compensacion.descuento:
        final cuenta = compraId == null ? null : _compras.cuentaDe(compraId);
        if (cuenta == null || cuenta.debe <= 0) {
          return const DevolucionSinFactura();
        }
        if (datos.total > cuenta.debe) {
          return DevolucionExcedeDeuda(debe: cuenta.debe);
        }
        completa = _con(datos, compraId: compraId);
      case Compensacion.dinero:
        final tasa = medio.moneda == Moneda.bolivares ? tasaDeHoy : null;
        final entregado = enMoneda(datos.total, medio.moneda, tasa);
        if (entregado == null) return const DevolucionSinTasa();
        completa = _con(datos, medio: medio, entregado: entregado, tasa: tasa);
      case Compensacion.repone:
        completa = datos;
    }
    final cambio = await _transacciones.enUna(
      () => _escribir(completa, incidencia),
    );
    _ultima = cambio;
    _poner([..._todas, cambio.devolucion]);
    return DevolucionRegistrada(cambio.devolucion);
  }

  Future<_Cambio> _escribir(
    DevolucionProveedor devolucion,
    Incidencia? incidencia,
  ) async {
    final productos = <({Producto antes, Producto despues})>[];
    final anotados = <Movimiento>[];
    if (devolucion.sacada) {
      for (final linea in devolucion.lineas) {
        final antes = _buscar(linea.productoId)!;
        final despues = sacarDeLote(
          antes,
          marca: linea.marca,
          proveedor: devolucion.proveedor,
          piezas: linea.piezas,
          cantidad: linea.cantidad,
        )!;
        await _existencias.actualizarProducto(
          antes.id,
          DatosProducto.desde(despues),
        );
        productos.add((antes: antes, despues: _buscar(antes.id)!));
        final anotado = await _movimientos?.anotar(
          Movimiento(
            fecha: devolucion.fecha,
            tipo: TipoMovimiento.devolucionProveedor,
            productoId: linea.productoId,
            producto: linea.producto,
            forma: linea.forma,
            marca: linea.marca,
            proveedor: devolucion.proveedor,
            piezas: linea.piezas,
            cantidad: linea.cantidad,
            nota: devolucion.motivo.etiqueta,
          ),
        );
        if (anotado != null) anotados.add(anotado);
      }
    }
    final guardada = await _repositorio.crear(devolucion);
    if (incidencia != null) {
      await _incidencias?.responder(incidencia, RespuestaProveedor.devuelto);
    }
    return (
      devolucion: guardada,
      productos: productos,
      anotados: anotados,
      incidencia: incidencia,
    );
  }

  /// Takes the last return back. Refused (false) when one of its products
  /// changed since, to not lose that change.
  Future<bool> deshacer() async {
    final ultima = _ultima;
    if (ultima == null) return false;
    _ultima = null;
    // Several lines of one product: only its last state must be untouched.
    final finales = {for (final p in ultima.productos) p.despues.id: p.despues};
    for (final despues in finales.values) {
      if (_buscar(despues.id) != despues) return false;
    }
    await _transacciones.enUna(() async {
      for (final p in ultima.productos.reversed) {
        await _existencias.actualizarProducto(
          p.antes.id,
          DatosProducto.desde(p.antes),
        );
      }
      for (final anotado in ultima.anotados) {
        await _movimientos?.quitar(anotado);
      }
      await _repositorio.borrar(ultima.devolucion.id);
      final incidencia = ultima.incidencia;
      if (incidencia != null) await _incidencias?.responder(incidencia, null);
    });
    _poner([
      for (final d in _todas)
        if (d.id != ultima.devolucion.id) d,
    ]);
    return true;
  }

  /// Marks the goods as brought again, or pending once more.
  Future<void> marcarRepuesta(DevolucionProveedor devolucion) async {
    if (devolucion.compensacion != Compensacion.repone) return;
    final cambiada = devolucion.conRepuesta(
      devolucion.repuesta == null ? _ahora() : null,
    );
    await _repositorio.actualizar(cambiada);
    _poner([for (final d in _todas) d.id == cambiada.id ? cambiada : d]);
  }

  /// Keeps returns linked when a supplier is renamed.
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    await _repositorio.renombrarProveedor(anterior, nuevo);
    await cargar();
  }

  void _poner(List<DevolucionProveedor> devoluciones) {
    _todas = [...devoluciones]..sort((a, b) => b.fecha.compareTo(a.fecha));
    _compras.fijarDevuelto(devueltoPorCompra(_todas));
    notifyListeners();
  }

  /// Lines of the same lot added up, to check the stock once per lot.
  static List<LineaCompra> _juntarPorLote(List<LineaCompra> lineas) {
    final juntas = <String, LineaCompra>{};
    for (final l in lineas) {
      final clave = '${l.productoId}|${normalizarParaBusqueda(l.marca)}';
      final previa = juntas[clave];
      juntas[clave] = previa == null
          ? l
          : LineaCompra(
              productoId: l.productoId,
              producto: l.producto,
              forma: l.forma,
              marca: l.marca,
              piezas: previa.piezas + l.piezas,
              cantidad: previa.cantidad + l.cantidad,
              costo: l.costo,
            );
    }
    return juntas.values.toList();
  }

  static DevolucionProveedor _con(
    DevolucionProveedor d, {
    String? compraId,
    MedioPago? medio,
    int? entregado,
    int? tasa,
  }) => DevolucionProveedor(
    fecha: d.fecha,
    proveedor: d.proveedor,
    motivo: d.motivo,
    lineas: d.lineas,
    compensacion: d.compensacion,
    compraId: compraId,
    medio: medio,
    entregado: entregado,
    tasa: tasa,
    nota: d.nota,
    incidenciaId: d.incidenciaId,
    sacada: d.sacada,
  );

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
