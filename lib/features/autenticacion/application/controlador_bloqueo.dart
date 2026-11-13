import 'package:flutter/foundation.dart';
import 'package:inventario/features/autenticacion/domain/almacen_bloqueo.dart';
import 'package:inventario/features/autenticacion/domain/minutos_bloqueo.dart';

/// How long the app waits with nobody touching it before locking itself.
class ControladorBloqueo extends ChangeNotifier {
  ControladorBloqueo(this._almacen);

  final AlmacenBloqueo _almacen;
  var _minutos = MinutosBloqueo.porDefecto;

  /// Zero while it never locks on its own.
  int get minutos => _minutos;

  Duration? get espera => _minutos == 0 ? null : Duration(minutes: _minutos);

  Future<void> cargar() async {
    _minutos = await _almacen.leerMinutos();
    notifyListeners();
  }

  Future<void> cambiar(int minutos) async {
    if (minutos == _minutos || !MinutosBloqueo.opciones.contains(minutos)) {
      return;
    }
    _minutos = minutos;
    notifyListeners();
    await _almacen.guardarMinutos(minutos);
  }
}
