import 'package:inventario/features/autenticacion/data/huella_pin.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/repositorio_autenticacion.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps only a salted hash of the PIN on the device. Until the user
/// changes it, the first PIN is [pinInicial].
class RepositorioAutenticacionPreferencias implements RepositorioAutenticacion {
  RepositorioAutenticacionPreferencias({
    required this.usuario,
    required this.pinInicial,
    SharedPreferencesAsync? preferencias,
  }) : _preferencias = preferencias ?? SharedPreferencesAsync();

  static const _claveHuella = 'autenticacion.huellaPin';

  final Usuario usuario;
  final Pin pinInicial;
  final SharedPreferencesAsync _preferencias;

  Future<bool> _esElPin(Pin pin) async {
    final huella = await _preferencias.getString(_claveHuella);
    if (huella == null) return pin == pinInicial;
    return HuellaPin.coincide(pin.digitos, huella);
  }

  /// A print from an older version is rewritten with today's rounds, now
  /// that the right PIN is at hand.
  Future<void> _ponerAlDia(Pin pin) async {
    final huella = await _preferencias.getString(_claveHuella);
    if (huella == null) return;
    final rondas = HuellaPin.iteracionesDe(huella);
    if (rondas == null || rondas >= HuellaPin.iteraciones) return;
    await _guardar(pin);
  }

  Future<void> _guardar(Pin pin) async =>
      _preferencias.setString(_claveHuella, await HuellaPin.crear(pin.digitos));

  @override
  Future<ResultadoInicioSesion> iniciarSesion({required Pin pin}) async {
    if (!await _esElPin(pin)) return const PinIncorrecto();
    await _ponerAlDia(pin);
    return InicioSesionCorrecto(usuario);
  }

  @override
  Future<ResultadoCambioPin> cambiarPin({
    required Pin actual,
    required Pin nuevo,
  }) async {
    if (!await _esElPin(actual)) return const PinActualIncorrecto();
    await _guardar(nuevo);
    return const PinCambiado();
  }
}
