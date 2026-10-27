import 'package:flutter/foundation.dart';
import 'package:inventario/features/ajustes/domain/ajuste.dart';
import 'package:inventario/features/ajustes/domain/resultado_ajuste.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

/// Takes mermas and losses out of the stock, notes them in the kardex and
/// remembers the last one so it can be undone.
class ControladorAjustes extends ChangeNotifier {
  ControladorAjustes(this._existencias, {this._movimientos});

  final ControladorExistencias _existencias;
  final ControladorMovimientos? _movimientos;
  ({Producto antes, Producto despues, Movimiento? anotado})? _ultimo;

  bool get puedeDeshacer => _ultimo != null;

  Future<ResultadoAjuste> registrar(String productoId, Ajuste ajuste) async {
    final antes = _buscar(productoId);
    final sacado = antes == null
        ? null
        : sacarDeLote(
            antes,
            marca: ajuste.marca,
            proveedor: ajuste.proveedor,
            piezas: ajuste.piezas,
            cantidad: ajuste.cantidad,
          );
    if (antes == null || sacado == null) return const AjusteSinExistencias();
    final resultado = await _existencias.actualizarProducto(
      productoId,
      DatosProducto.desde(sacado),
    );
    switch (resultado) {
      case ProductoGuardado(:final producto):
        final anotado = await _movimientos?.anotar(
          Movimiento(
            fecha: DateTime.now(),
            tipo: ajuste.tipo.movimiento,
            productoId: productoId,
            producto: antes.nombre,
            forma: antes.forma,
            marca: ajuste.marca,
            proveedor: ajuste.proveedor,
            piezas: ajuste.piezas,
            cantidad: ajuste.cantidad,
            nota: [
              ajuste.motivo,
              if (ajuste.nota.isNotEmpty) ajuste.nota,
            ].join(' · '),
          ),
        );
        _ultimo = (antes: antes, despues: producto, anotado: anotado);
        notifyListeners();
        return AjusteRegistrado(producto);
      // The name is unchanged, so it cannot clash with another product.
      case NombreRepetido():
        return const AjusteSinExistencias();
    }
  }

  /// Puts the goods back. Refused (false) when the product changed since.
  Future<bool> deshacer() async {
    final ultimo = _ultimo;
    if (ultimo == null) return false;
    _ultimo = null;
    notifyListeners();
    if (_buscar(ultimo.despues.id) != ultimo.despues) return false;
    final resultado = await _existencias.actualizarProducto(
      ultimo.antes.id,
      DatosProducto.desde(ultimo.antes),
    );
    if (ultimo.anotado case final anotado?) {
      await _movimientos?.quitar(anotado);
    }
    return resultado is ProductoGuardado;
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
