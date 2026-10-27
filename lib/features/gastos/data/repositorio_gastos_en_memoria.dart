import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/gastos/domain/repositorio_gastos.dart';

/// For tests; lost when the app closes.
class RepositorioGastosEnMemoria implements RepositorioGastos {
  RepositorioGastosEnMemoria([List<Gasto> iniciales = const []])
    : _gastos = [...iniciales];

  final List<Gasto> _gastos;
  var _ultimoId = 0;

  @override
  Future<List<Gasto>> obtenerTodos() async => List.unmodifiable(_gastos);

  @override
  Future<Gasto> crear(Gasto gasto) async {
    final guardado = gasto.conId('g${++_ultimoId}');
    _gastos.add(guardado);
    return guardado;
  }

  @override
  Future<void> quitar(String id) async =>
      _gastos.removeWhere((g) => g.id == id);
}
