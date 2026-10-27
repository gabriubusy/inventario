import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inventario/features/autenticacion/application/estado_sesion.dart';
import 'package:inventario/features/autenticacion/domain/almacen_sesion.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/repositorio_autenticacion.dart';
import 'package:inventario/features/autenticacion/domain/resultado_cambio_pin.dart';
import 'package:inventario/features/autenticacion/domain/resultado_inicio_sesion.dart';

class ControladorSesion extends ChangeNotifier {
  ControladorSesion(this._repositorio, this._almacen);

  final RepositorioAutenticacion _repositorio;
  final AlmacenSesion _almacen;
  EstadoSesion _estado = const SesionCerrada();

  EstadoSesion get estado => _estado;

  /// Reopens the session saved before a reload, if any.
  Future<void> restaurar() async {
    final usuario = await _almacen.leer();
    if (usuario != null) _cambiar(SesionAbierta(usuario));
  }

  Future<void> iniciarSesion({required Pin pin}) async {
    if (_estado is IniciandoSesion) return;
    _cambiar(const IniciandoSesion());
    final resultado = await _repositorio.iniciarSesion(pin: pin);
    switch (resultado) {
      case InicioSesionCorrecto(:final usuario):
        await _almacen.guardar(usuario);
        _cambiar(SesionAbierta(usuario));
      case PinIncorrecto():
        _cambiar(const SesionCerrada(pinIncorrecto: true));
    }
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
