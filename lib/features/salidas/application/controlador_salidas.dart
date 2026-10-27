import 'package:flutter/foundation.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';
import 'package:inventario/features/salidas/domain/devolver_venta.dart';
import 'package:inventario/features/salidas/domain/modo_venta.dart';
import 'package:inventario/features/salidas/domain/resultado_anulacion.dart';
import 'package:inventario/features/salidas/domain/resultado_salida.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/domain/vender.dart';

/// Takes sold goods out of the stock and remembers the last sale so it can
/// be undone. Also remembers how each product was last sold, to offer it.
class ControladorSalidas extends ChangeNotifier {
  ControladorSalidas(this._existencias, {this._movimientos});

  final ControladorExistencias _existencias;

  /// Where each sale is noted for the day's history; optional in tests.
  final ControladorMovimientos? _movimientos;
  final _ultimoModo = <String, ModoVenta>{};
  ({Producto antes, Producto despues, Movimiento? anotado})? _ultima;

  bool get puedeDeshacer => _ultima != null;

  /// Whole piece unless this product was last sold by weight.
  ModoVenta modoPara(String productoId) =>
      _ultimoModo[productoId] ?? ModoVenta.piezaEntera;

  Future<ResultadoSalida> registrar(String productoId, Salida salida) async {
    final antes = _buscar(productoId);
    if (antes == null) return const SalidaSinProducto();
    final despues = vender(antes, salida);
    if (despues == null) return const SinExistencias();
    final resultado = await _existencias.actualizarProducto(
      productoId,
      DatosProducto.desde(despues),
    );
    switch (resultado) {
      case ProductoGuardado(:final producto):
        if (salida.modo case final modo?) _ultimoModo[productoId] = modo;
        final lote = antes.lotes[indiceLoteDeSalida(antes, salida)];
        final anotado = await _movimientos?.anotar(
          Movimiento(
            fecha: DateTime.now(),
            tipo: TipoMovimiento.venta,
            productoId: productoId,
            producto: antes.nombre,
            forma: antes.forma,
            marca: salida.marca,
            proveedor: salida.proveedor,
            piezas: salida.piezas,
            cantidad: salida.cantidad,
            importe: importeDeSalida(
              antes,
              lote,
              salida.cantidad,
              presentacion: salida.presentacion,
            ),
            abrioPieza: abrePieza(lote, salida.modo),
          ),
        );
        _ultima = (antes: antes, despues: producto, anotado: anotado);
        notifyListeners();
        return SalidaRegistrada(producto);
      // The name is unchanged, so it cannot clash with another product.
      case NombreRepetido():
        return const SalidaSinProducto();
    }
  }

  /// Puts the product back as it was before the last sale. Refused (false)
  /// when something else changed that product since, to not lose it.
  Future<bool> deshacer() async {
    final ultima = _ultima;
    if (ultima == null) return false;
    _ultima = null;
    notifyListeners();
    if (_buscar(ultima.despues.id) != ultima.despues) return false;
    final resultado = await _existencias.actualizarProducto(
      ultima.antes.id,
      DatosProducto.desde(ultima.antes),
    );
    if (ultima.anotado case final anotado?) {
      await _movimientos?.quitar(anotado);
    }
    return resultado is ProductoGuardado;
  }

  /// Gives a sale's goods back to its brand lot and keeps the sale in the
  /// day's list, crossed out. Unlike undo, it works on any sale of the day.
  Future<ResultadoAnulacion> anular(Movimiento venta) async {
    if (venta.anulada) return const YaAnulada();
    final producto = _buscar(venta.productoId);
    if (producto == null) return const AnulacionSinProducto();
    final devuelto = devolverVenta(
      producto,
      marca: venta.marca,
      proveedor: venta.proveedor,
      piezas: venta.piezas,
      cantidad: venta.cantidad,
      abrioPieza: venta.abrioPieza,
    );
    await _existencias.actualizarProducto(
      producto.id,
      DatosProducto.desde(devuelto),
    );
    await _movimientos?.anular(venta.id);
    // That sale can no longer be undone on top of the cancellation.
    if (_ultima?.anotado?.id == venta.id) _ultima = null;
    notifyListeners();
    return const VentaAnulada();
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
