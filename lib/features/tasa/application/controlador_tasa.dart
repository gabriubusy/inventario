import 'package:flutter/foundation.dart';
import 'package:inventario/features/tasa/domain/almacen_tasa.dart';
import 'package:inventario/features/tasa/domain/fuente_tasa.dart';
import 'package:inventario/features/tasa/domain/origen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

class ControladorTasa extends ChangeNotifier {
  ControladorTasa(this._almacen, {this._fuente, DateTime Function()? ahora})
    : _ahora = ahora ?? DateTime.now;

  final AlmacenTasa _almacen;
  final FuenteTasa? _fuente;
  final DateTime Function() _ahora;
  TasaCambio? _tasa;
  var _consultando = false;
  var _sinRespuesta = false;

  /// True while asking the internet for today's rate.
  bool get consultando => _consultando;

  /// The last attempt got no rate (no internet, service down); type it in.
  bool get sinRespuesta => _sinRespuesta;

  /// The latest saved rate, even if it is from an earlier day.
  TasaCambio? get tasa => _tasa;

  /// False until today's rate is in; prices then use the last one.
  bool get esDeHoy => _tasa?.esDelDia(_ahora()) ?? false;

  DateTime get hoy => _ahora();

  Future<void> cargar() async {
    _tasa = await _almacen.leer();
    notifyListeners();
  }

  /// Fetches today's BCV rate unless there already is one for today.
  /// Without internet the last rate stays and the screens keep warning.
  Future<void> actualizarDesdeInternet() async {
    final fuente = _fuente;
    if (fuente == null || esDeHoy || _consultando) return;
    _consultando = true;
    notifyListeners();
    final resultado = await fuente.consultar();
    _consultando = false;
    switch (resultado) {
      // A rate typed by hand meanwhile wins over the fetched one.
      case TasaObtenida(:final bolivaresPorDolar, :final anterior)
          when !esDeHoy:
        await guardar(
          bolivaresPorDolar,
          origen: OrigenTasa.bcv,
          anterior: anterior,
        );
      case TasaObtenida():
        notifyListeners();
      case TasaNoDisponible():
        _sinRespuesta = true;
        notifyListeners();
    }
  }

  /// [bolivaresPorDolar] in hundredths. Without [anterior], the change is
  /// measured against the last saved day's rate.
  Future<void> guardar(
    int bolivaresPorDolar, {
    OrigenTasa origen = OrigenTasa.manual,
    int? anterior,
  }) async {
    final tasa = TasaCambio(
      bolivaresPorDolar: bolivaresPorDolar,
      fecha: _ahora(),
      origen: origen,
      anterior: anterior ?? _anteriorA(_ahora()),
    );
    await _almacen.guardar(tasa);
    _tasa = tasa;
    _sinRespuesta = false;
    notifyListeners();
  }

  /// Null until a rate has been saved at least once.
  int? aBolivares(int dolares) => _tasa?.aBolivares(dolares);

  /// A correction on the same day keeps comparing with the day before.
  int? _anteriorA(DateTime dia) {
    final actual = _tasa;
    if (actual == null) return null;
    return actual.esDelDia(dia) ? actual.anterior : actual.bolivaresPorDolar;
  }
}
