import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/gastos/domain/repositorio_gastos.dart';

/// Business expenses and other income (Ctrl+G); the last one can be undone.
class ControladorGastos extends ChangeNotifier {
  ControladorGastos(
    this._repositorio, {
    this._tasaDeHoy,
    this._ahora = DateTime.now,
  });

  final RepositorioGastos _repositorio;
  final int? Function()? _tasaDeHoy;
  final DateTime Function() _ahora;
  List<Gasto> _todos = const [];
  Gasto? _ultimo;

  /// Newest first.
  List<Gasto> get todos => _todos;
  int? get tasaDeHoy => _tasaDeHoy?.call();

  Future<void> cargar() async => _poner(await _repositorio.obtenerTodos());

  Future<Gasto> registrar({
    required CategoriaGasto categoria,
    required MedioPago medio,
    required int monto,
    String nota = '',
  }) async {
    final guardado = await _repositorio.crear(
      Gasto(
        fecha: _ahora(),
        categoria: categoria,
        medio: medio,
        monto: monto,
        tasa: tasaDeHoy,
        nota: nota,
      ),
    );
    _ultimo = guardado;
    _poner([..._todos, guardado]);
    return guardado;
  }

  Future<void> deshacer() async {
    final ultimo = _ultimo;
    if (ultimo == null) return;
    _ultimo = null;
    await _repositorio.quitar(ultimo.id);
    _poner([
      for (final g in _todos)
        if (g.id != ultimo.id) g,
    ]);
  }

  void _poner(List<Gasto> gastos) {
    _todos = [...gastos]..sort((a, b) => b.fecha.compareTo(a.fecha));
    notifyListeners();
  }
}
