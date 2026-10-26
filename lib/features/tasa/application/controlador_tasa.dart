import 'package:flutter/foundation.dart';
import 'package:inventario/features/tasa/domain/almacen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

class ControladorTasa extends ChangeNotifier {
  ControladorTasa(this._almacen, {DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final AlmacenTasa _almacen;
  final DateTime Function() _ahora;
  TasaCambio? _tasa;

  /// The latest saved rate, even if it is from an earlier day.
  TasaCambio? get tasa => _tasa;

  /// False until today's rate is entered; prices then use the last one.
  bool get esDeHoy => _tasa?.esDelDia(_ahora()) ?? false;

  DateTime get hoy => _ahora();

  Future<void> cargar() async {
    _tasa = await _almacen.leer();
    notifyListeners();
  }

  /// [bolivaresPorDolar] in hundredths.
  Future<void> guardar(int bolivaresPorDolar) async {
    final tasa = TasaCambio(
      bolivaresPorDolar: bolivaresPorDolar,
      fecha: _ahora(),
    );
    await _almacen.guardar(tasa);
    _tasa = tasa;
    notifyListeners();
  }

  /// Null until a rate has been saved at least once.
  int? aBolivares(int dolares) => _tasa?.aBolivares(dolares);
}
