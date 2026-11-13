import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/domain/almacen_sesion.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/repositorio_autenticacion.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';

class ControladorSesion extends ChangeNotifier {
  ControladorSesion(
    this._repositorio,
    this._almacen, {
    DateTime Function()? ahora,
  }) : _ahora = ahora ?? DateTime.now;

  /// Wrong PINs that cost nothing: a slip is usually the first or second.
  static const _fallosLibres = 2;

  /// What each further wrong PIN waits, the last one from then on.
  static const _esperas = [
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];

  final RepositorioAutenticacion _repositorio;
  final AlmacenSesion _almacen;
  final DateTime Function() _ahora;
  EstadoSesion _estado = const SesionCerrada();
  var _fallos = 0;
  DateTime? _esperaHasta;

  EstadoSesion get estado => _estado;

  /// How long until another PIN is taken; zero while nothing is waiting.
  Duration get esperaRestante {
    final hasta = _esperaHasta;
    if (hasta == null) return Duration.zero;
    final falta = hasta.difference(_ahora());
    return falta.isNegative ? Duration.zero : falta;
  }

  /// Reopens the session saved before a reload, if any.
  Future<void> restaurar() async {
    final usuario = await _almacen.leer();
    if (usuario != null) _cambiar(SesionAbierta(usuario));
  }

  Future<void> iniciarSesion({required Pin pin}) async {
    if (_estado is IniciandoSesion || esperaRestante > Duration.zero) return;
    _cambiar(const IniciandoSesion());
    final resultado = await _repositorio.iniciarSesion(pin: pin);
    switch (resultado) {
      case InicioSesionCorrecto(:final usuario):
        _fallos = 0;
        _esperaHasta = null;
        await _almacen.guardar(usuario);
        _cambiar(SesionAbierta(usuario));
      case PinIncorrecto():
        _fallos++;
        final espera = _esperaTras(_fallos);
        _esperaHasta = espera == Duration.zero ? null : _ahora().add(espera);
        _cambiar(SesionCerrada(pinIncorrecto: true, esperaHasta: _esperaHasta));
    }
  }

  Duration _esperaTras(int fallos) {
    final paso = fallos - _fallosLibres - 1;
    if (paso < 0) return Duration.zero;
    return _esperas[paso < _esperas.length ? paso : _esperas.length - 1];
  }

  Future<ResultadoCambioPin> cambiarPin({
    required Pin actual,
    required Pin nuevo,
  }) => _repositorio.cambiarPin(actual: actual, nuevo: nuevo);

  /// Locks at once; the saved session is wiped in the background.
  void cerrarSesion() {
    _cambiar(const SesionCerrada());
    unawaited(_almacen.borrar());
  }

  void _cambiar(EstadoSesion estado) {
    _estado = estado;
    notifyListeners();
  }
}
