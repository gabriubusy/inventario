import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/caja/domain/repositorio_cajas.dart';

/// For tests; lost when the app closes.
class RepositorioCajasEnMemoria implements RepositorioCajas {
  RepositorioCajasEnMemoria([List<Caja> iniciales = const []])
    : _cajas = [...iniciales];

  final List<Caja> _cajas;
  var _ultimoId = 0;

  @override
  Future<List<Caja>> obtenerTodas() async => List.unmodifiable(_cajas);

  @override
  Future<Caja> abrir(Caja caja) async {
    final guardada = caja.conId('k${++_ultimoId}');
    _cajas.add(guardada);
    return guardada;
  }

  @override
  Future<void> cerrar(Caja caja) async {
    final i = _cajas.indexWhere((c) => c.id == caja.id);
    if (i != -1) _cajas[i] = caja;
  }
}
