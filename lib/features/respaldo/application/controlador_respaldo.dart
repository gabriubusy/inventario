import 'package:flutter/foundation.dart';
import 'package:inventario/features/configuracion/domain/ajustes_respaldo.dart';
import 'package:inventario/features/configuracion/domain/almacen_ajustes_respaldo.dart';
import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';
import 'package:inventario/features/respaldo/domain/gestor_respaldos.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

/// Backups: when the last one was, where they go, making one, the home
/// reminder and preparing a restore.
class ControladorRespaldo extends ChangeNotifier {
  ControladorRespaldo(
    this._gestor,
    this._almacen, {
    this._ahora = DateTime.now,
  });

  final GestorRespaldos _gestor;
  final AlmacenAjustesRespaldo _almacen;
  final DateTime Function() _ahora;
  AjustesRespaldo _ajustes = const AjustesRespaldo();
  var _cargado = false;

  AjustesRespaldo get ajustes => _ajustes;
  bool get disponible => _gestor.disponible;

  /// The home reminder shows; never before the settings are read.
  bool get hayQueRecordar =>
      _cargado && disponible && _ajustes.hayQueRecordar(_ahora());

  int? get diasSinRespaldo => _ajustes.diasSinRespaldo(_ahora());

  Future<void> cargar() async {
    _ajustes = await _almacen.leer();
    _cargado = true;
    notifyListeners();
  }

  /// Into [carpeta], or the saved folder; that folder is remembered.
  Future<ResultadoRespaldo> respaldar({String? carpeta}) async {
    final destino = carpeta ?? _ajustes.carpeta;
    if (destino == null) return const CarpetaNoDisponible('');
    final resultado = await _gestor.respaldar(destino, fecha: _ahora());
    if (resultado is RespaldoGuardado) {
      await _guardar(_ajustes.copyWith(carpeta: destino, ultimo: _ahora()));
    }
    return resultado;
  }

  Future<void> cambiarCarpeta(String carpeta) =>
      _guardar(_ajustes.copyWith(carpeta: carpeta));

  Future<void> cambiarDias(int dias) =>
      _guardar(_ajustes.copyWith(diasRecordatorio: dias));

  /// "Mañana": hides the reminder for the rest of today.
  Future<void> posponer() {
    final hoy = _ahora();
    return _guardar(
      _ajustes.copyWith(pospuestoHasta: DateTime(hoy.year, hoy.month, hoy.day)),
    );
  }

  Future<List<ArchivoRespaldo>> respaldosGuardados() async {
    final carpeta = _ajustes.carpeta;
    return carpeta == null ? const [] : _gestor.enCarpeta(carpeta);
  }

  Future<ResultadoRespaldo> prepararRestauracion(String archivo) =>
      _gestor.prepararRestauracion(archivo, fecha: _ahora());

  void cerrarApp() => _gestor.cerrarApp();

  Future<void> _guardar(AjustesRespaldo ajustes) async {
    await _almacen.guardar(ajustes);
    _ajustes = ajustes;
    notifyListeners();
  }
}
