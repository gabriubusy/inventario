import 'package:inventario/features/salidas/domain/repositorio_ventas.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

/// For tests; the app keeps sales in SQLite.
class RepositorioVentasEnMemoria implements RepositorioVentas {
  final _ventas = <Venta>[];
  var _ultimoId = 0;

  @override
  Future<List<Venta>> obtenerTodas() async => List.unmodifiable(_ventas);

  @override
  Future<Venta> registrar(Venta venta) async {
    final guardada = venta.conId('t${++_ultimoId}');
    _ventas.add(guardada);
    return guardada;
  }

  @override
  Future<void> quitar(String id) async =>
      _ventas.removeWhere((v) => v.id == id);
}
