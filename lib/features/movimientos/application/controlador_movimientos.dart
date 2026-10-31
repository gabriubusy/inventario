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

  /// True when nothing was noted after [movimientos], so undoing them only
  /// takes back the latest thing that happened.
  bool sonLosUltimos(List<Movimiento> movimientos) {
    final ids = {for (final m in movimientos) m.id};
    return _todos.take(ids.length).every((m) => ids.contains(m.id));
  }

  /// Today's sales, newest first, cancelled ones included.
  List<Movimiento> get ventasDeHoy => ventasDelDia(hoy);

  /// Sales of the calendar day of [dia], newest first, cancelled included.
  List<Movimiento> ventasDelDia(DateTime dia) => [
    for (final m in _todos)
      if (m.tipo == TipoMovimiento.venta && diasEntre(m.fecha, dia) == 0) m,
  ];

  /// Keeps the sale in the list, crossed out; the stock goes back elsewhere.
  Future<void> anular(String id) async {
    final el = _ahora();
    await _repositorio.anular(id, el: el);
    _poner([for (final m in _todos) m.id == id ? m.anulado(el) : m]);
  }

  Future<void> quitar(Movimiento movimiento) async {
    await _repositorio.quitar(movimiento.id);
    _poner([
      for (final m in _todos)
        if (m.id != movimiento.id) m,
    ]);
  }

  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    await _repositorio.renombrarProveedor(anterior, nuevo);
    _poner(await _repositorio.obtenerTodos());
  }

  void _poner(List<Movimiento> movimientos) {
    _todos = [...movimientos]..sort((a, b) => b.fecha.compareTo(a.fecha));
    notifyListeners();
  }
}
