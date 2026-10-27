import 'package:flutter/foundation.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/entradas/domain/resultado_entrada.dart';
import 'package:inventario/features/entradas/domain/sumar_entrada.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

/// Records goods received and remembers the last entry so it can be undone.
class ControladorEntradas extends ChangeNotifier {
  ControladorEntradas(this._existencias, {this._movimientos});

  final ControladorExistencias _existencias;

  /// Where each entry is noted for the day's history; optional in tests.
  final ControladorMovimientos? _movimientos;
  ({Producto antes, Producto despues, Movimiento? anotado})? _ultima;

  bool get puedeDeshacer => _ultima != null;

  Future<ResultadoEntrada> registrar(String productoId, Entrada entrada) async {
    final antes = _buscar(productoId);
    if (antes == null) return const ProductoNoEncontrado();
    final resultado = await _existencias.actualizarProducto(
      productoId,
      DatosProducto.desde(sumarEntrada(antes, entrada)),
    );
    switch (resultado) {
      case ProductoGuardado(:final producto):
        final anotado = await _movimientos?.anotar(
          Movimiento(
            fecha: DateTime.now(),
            tipo: TipoMovimiento.entrada,
            productoId: productoId,
            producto: antes.nombre,
            forma: antes.forma,
            marca: entrada.marca,
            piezas: entrada.piezas,
            cantidad: entrada.cantidad,
          ),
        );
        _ultima = (antes: antes, despues: producto, anotado: anotado);
        notifyListeners();
        return EntradaRegistrada(producto);
      // The name is unchanged, so it cannot clash with another product.
      case NombreRepetido():
        return const ProductoNoEncontrado();
    }
  }

  /// Puts the product back as it was before the last entry. Refused (false)
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

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
