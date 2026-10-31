import 'package:flutter/foundation.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/conteo/domain/aplicar_conteo.dart';
import 'package:inventario/features/conteo/domain/conteo_lote.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

/// One lot changed by a count, and its kardex line.
typedef _Cambio = ({Producto antes, Producto despues, Movimiento? anotado});

/// Sets the stock to what was physically counted, noting each difference
/// in the kardex. The last save can be undone as a whole.
class ControladorConteo extends ChangeNotifier {
  ControladorConteo(
    this._existencias, {
    this._movimientos,
    this._transacciones = const SinTransaccion(),
  });

  final ControladorExistencias _existencias;

  /// A whole count is saved, or undone, as one.
  final Transacciones _transacciones;
  final ControladorMovimientos? _movimientos;
  List<_Cambio> _ultimos = const [];

  bool get puedeDeshacer => _ultimos.isNotEmpty;

  /// What was typed but not saved, by lot, so leaving F9 by mistake (Esc)
  /// loses nothing. Emptied once the count is saved.
  Map<String, ({String piezas, String cantidad})> borrador = const {};

  /// Saves every count that differs; returns how many lots changed.
  Future<int> guardar(List<ConteoLote> conteos) async {
    final cambios = <_Cambio>[];
    await _transacciones.enUna(() => _escribirConteos(conteos, cambios));
    _ultimos = cambios;
    notifyListeners();
    return cambios.length;
  }

  Future<void> _escribirConteos(
    List<ConteoLote> conteos,
    List<_Cambio> cambios,
  ) async {
    for (final conteo in conteos) {
      final antes = _buscar(conteo.productoId);
      if (antes == null) continue;
      final indice = indiceLote(antes, conteo.marca, conteo.proveedor);
      if (indice == -1) continue;
      final diferencia = diferenciaConteo(antes.lotes[indice], conteo);
      final despues = aplicarConteo(antes, conteo);
      if (!hayDiferencia(diferencia) || despues == null) continue;
      final resultado = await _existencias.actualizarProducto(
        antes.id,
        DatosProducto.desde(despues),
      );
      if (resultado case ProductoGuardado(:final producto)) {
        final anotado = await _anotar(antes, conteo, diferencia);
        cambios.add((antes: antes, despues: producto, anotado: anotado));
      }
    }
  }

  /// Puts back every product of the last save that nobody changed since;
  /// returns how many lots could not be undone. Their kardex lines stay.
  Future<int> deshacer() async {
    final ultimos = _ultimos;
    _ultimos = const [];
    notifyListeners();
    // Two lots of one product: the first "before" and the last "after".
    final porProducto = <String, List<_Cambio>>{};
    for (final cambio in ultimos) {
      (porProducto[cambio.antes.id] ??= []).add(cambio);
    }
    return _transacciones.enUna(() async {
      var fallidos = 0;
      for (final cambios in porProducto.values) {
        if (_buscar(cambios.first.antes.id) != cambios.last.despues) {
          fallidos += cambios.length;
          continue;
        }
        await _existencias.actualizarProducto(
          cambios.first.antes.id,
          DatosProducto.desde(cambios.first.antes),
        );
        for (final cambio in cambios) {
          if (cambio.anotado case final anotado?) {
            await _movimientos?.quitar(anotado);
          }
        }
      }
      return fallidos;
    });
  }

  Future<Movimiento?> _anotar(
    Producto antes,
    ConteoLote conteo,
    DiferenciaConteo diferencia,
  ) async {
    // The weight decides the direction; pieces follow it.
    final falta =
        diferencia.cantidad < 0 ||
        (diferencia.cantidad == 0 && diferencia.piezas < 0);
    return _movimientos?.anotar(
      Movimiento(
        fecha: DateTime.now(),
        tipo: falta ? TipoMovimiento.conteoFalta : TipoMovimiento.conteoSobra,
        productoId: antes.id,
        producto: antes.nombre,
        forma: antes.forma,
        marca: conteo.marca,
        proveedor: conteo.proveedor,
        piezas: diferencia.piezas.abs(),
        cantidad: diferencia.cantidad.abs(),
        nota: 'Contado ${antes.forma.unidad.formatear(conteo.cantidad)}',
      ),
    );
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
