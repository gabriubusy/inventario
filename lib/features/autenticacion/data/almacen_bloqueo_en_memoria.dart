import 'package:inventario/features/autenticacion/domain/almacen_bloqueo.dart';
import 'package:inventario/features/autenticacion/domain/minutos_bloqueo.dart';

/// For tests; forgotten when the app closes.
class AlmacenBloqueoEnMemoria implements AlmacenBloqueo {
  AlmacenBloqueoEnMemoria([this._minutos = MinutosBloqueo.porDefecto]);

  int _minutos;

  @override
  Future<int> leerMinutos() async => _minutos;

  @override
  Future<void> guardarMinutos(int minutos) async => _minutos = minutos;
}
