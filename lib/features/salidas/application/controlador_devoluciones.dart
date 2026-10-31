import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/salidas/domain/devolucion_cliente.dart';
import 'package:inventario/features/salidas/domain/devolver_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_devolucion.dart';

/// Customer returns of any day's sales. Goods that are fine go back to their
/// brand lot; damaged ones are noted as returned and then lost (merma).
class ControladorDevoluciones extends ChangeNotifier {
  ControladorDevoluciones(
    this._existencias,
    this._movimientos, {
    this._transacciones = const SinTransaccion(),
  });

  final ControladorExistencias _existencias;

  /// Stock and history change together or not at all.
  final Transacciones _transacciones;
  final ControladorMovimientos _movimientos;
  ({Producto? antes, Producto? despues, List<Movimiento> anotados})? _ultima;

  bool get puedeDeshacer => _ultima != null;

  int devolvibleDe(Movimiento venta) => devolvible(venta, _movimientos.todos);

  /// What [cantidad] of [venta] gives back; the last part takes what is
  /// left, so the parts never add up to more. The window shows the same.
  int? importeADevolver(Movimiento venta, int cantidad) {
    if (cantidad != devolvibleDe(venta)) {
      return importeDevuelto(venta, cantidad);
    }
    final previas = devolucionesDe(venta, _movimientos.todos);
    return restante(venta.importe, previas.map((m) => m.importe));
  }

  Future<ResultadoDevolucion> devolver(
    Movimiento venta, {
    required int cantidad,
    required DestinoDevolucion destino,
    MedioPago medio = MedioPago.efectivoDolares,
    String nota = '',
  }) async {
    final queda = devolvibleDe(venta);
    if (cantidad <= 0 || cantidad > queda) return const DevolucionExcede();
    final antes = _buscar(venta.productoId);
    if (antes == null) return const DevolucionSinProducto();
    // A whole piece only comes back as a piece when it returns untouched.
    final entera = queda == venta.cantidad && cantidad == venta.cantidad;
    final importe = importeADevolver(venta, cantidad);
    // The cost comes back only with the goods; damaged ones stay a loss.
    // The last part's share is what the earlier parts left, wherever they went.
    // Zero, not null, for damaged goods: null is kept for older returns.
    final costo = destino == DestinoDevolucion.merma
        ? 0
        : cantidad == queda
        ? restante(venta.costo, [
            proporcional(venta.costo, venta.cantidad - queda, venta.cantidad),
          ])
        : proporcional(venta.costo, cantidad, venta.cantidad);
    Movimiento base(TipoMovimiento tipo, String texto) {
      final esDevolucion = tipo == TipoMovimiento.devolucionCliente;
      return Movimiento(
        fecha: DateTime.now(),
        tipo: tipo,
        productoId: venta.productoId,
        producto: venta.producto,
        forma: venta.forma,
        marca: venta.marca,
        proveedor: venta.proveedor,
        piezas: entera ? venta.piezas : 0,
        cantidad: cantidad,
        importe: esDevolucion ? importe : null,
        costo: esDevolucion ? costo : null,
        // The refund in Bs uses the sale's rate, not today's.
        tasa: esDevolucion ? venta.tasa : null,
        nota: texto,
        origenId: esDevolucion ? venta.id : null,
        medioReembolso: esDevolucion ? medio : null,
      );
    }

    final detalle = [destino.etiqueta, if (nota.isNotEmpty) nota].join(' · ');
    final (:despues, :anotados) = await _transacciones.enUna(() async {
      Producto? despues;
      if (destino == DestinoDevolucion.stock) {
        final devuelto = devolverVenta(
          antes,
          marca: venta.marca,
          proveedor: venta.proveedor,
          piezas: entera ? venta.piezas : 0,
          cantidad: cantidad,
          abrioPieza: false,
        );
        await _existencias.actualizarProducto(
          antes.id,
          DatosProducto.desde(devuelto),
        );
        despues = _buscar(antes.id);
      }
      final anotados = [
        await _movimientos.anotar(
          base(TipoMovimiento.devolucionCliente, detalle),
        ),
        if (destino == DestinoDevolucion.merma)
          await _movimientos.anotar(
            base(TipoMovimiento.merma, 'Devolución de cliente dañada'),
          ),
      ];
      return (despues: despues, anotados: anotados);
    });
    _ultima = (
      antes: despues == null ? null : antes,
      despues: despues,
      anotados: anotados,
    );
    notifyListeners();
    return DevolucionRegistrada(importe: importe);
  }

  /// Takes the last return back. Refused (false) when the product changed
  /// since it went back to the stock.
  Future<bool> deshacer() async {
    final ultima = _ultima;
    if (ultima == null) return false;
    _ultima = null;
    notifyListeners();
    final antes = ultima.antes;
    final despues = ultima.despues;
    if (despues != null && _buscar(despues.id) != despues) return false;
    return _transacciones.enUna(() async {
      if (antes != null) {
        await _existencias.actualizarProducto(
          antes.id,
          DatosProducto.desde(antes),
        );
      }
      for (final anotado in ultima.anotados) {
        await _movimientos.quitar(anotado);
      }
      return true;
    });
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
