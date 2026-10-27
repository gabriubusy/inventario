import 'package:flutter/foundation.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/repositorio_movimientos.dart';
import 'package:inventario/features/movimientos/domain/resumen_dia.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';

/// History of sales and entries, newest first, for the home screen.
class ControladorMovimientos extends ChangeNotifier {
  ControladorMovimientos(this._repositorio, {this._ahora = DateTime.now});

  final RepositorioMovimientos _repositorio;
  final DateTime Function() _ahora;
  List<Movimiento> _todos = const [];

  DateTime get hoy => _ahora();

  /// Newest first.
  List<Movimiento> get todos => _todos;

  ResumenDia get resumenDeHoy => ResumenDia.de(_todos, hoy);

  /// Today's sales, newest first, at most [limite].
  List<Movimiento> ultimasVentas({int limite = 7}) => _todos
      .where(
        (m) => m.tipo == TipoMovimiento.venta && diasEntre(m.fecha, hoy) == 0,
      )
      .take(limite)
      .toList();

  Future<void> cargar() async => _poner(await _repositorio.obtenerTodos());

  /// [fecha] is filled with now; returns it as stored, to undo it later.
  Future<Movimiento> anotar(Movimiento movimiento) async {
    final guardado = await _repositorio.anotar(movimiento.conFecha(_ahora()));
    _poner([..._todos, guardado]);
    return guardado;
  }

  /// Today's sales, newest first, cancelled ones included.
  List<Movimiento> get ventasDeHoy => ultimasVentas(limite: _todos.length);

  /// Keeps the sale in the list, crossed out; the stock goes back elsewhere.
  Future<void> anular(String id) async {
    await _repositorio.anular(id);
    _poner([for (final m in _todos) m.id == id ? m.anulado() : m]);
  }

  Future<void> quitar(Movimiento movimiento) async {
    await _repositorio.quitar(movimiento.id);
    _poner([
      for (final m in _todos)
        if (m.id != movimiento.id) m,
    ]);
  }

  void _poner(List<Movimiento> movimientos) {
    _todos = [...movimientos]..sort((a, b) => b.fecha.compareTo(a.fecha));
    notifyListeners();
  }
}
