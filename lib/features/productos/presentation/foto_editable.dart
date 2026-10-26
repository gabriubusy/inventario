import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_imagen.dart';
import 'package:inventario/features/productos/presentation/elegir_imagen.dart';

/// Photo being chosen in the product form. Photos uploaded here and never
/// saved are deleted when the form goes away; saved ones are left alone.
class FotoEditable extends ChangeNotifier {
  FotoEditable(this._fotos, this._elegir, {String? inicial}) : _id = inicial;

  final GestorFotos _fotos;
  final ElegirImagen _elegir;
  final _subidas = <String>{};
  String? _id;
  var _cargando = false;
  var _noValida = false;
  var _desechada = false;

  String? get id => _id;
  bool get cargando => _cargando;
  bool get noValida => _noValida;

  Future<void> elegir() async {
    if (_cargando) return;
    final bytes = await _elegir();
    if (bytes == null || _desechada) return;
    _cargando = true;
    _noValida = false;
    notifyListeners();
    final resultado = await _fotos.guardar(bytes);
    if (_desechada) {
      if (resultado case ImagenGuardada(:final id)) {
        unawaited(_fotos.borrar(id));
      }
      return;
    }
    _cargando = false;
    switch (resultado) {
      case ImagenGuardada(:final id):
        _soltar(_id);
        _id = id;
        _subidas.add(id);
      case ImagenNoValida():
        _noValida = true;
    }
    notifyListeners();
  }

  void quitar() {
    _soltar(_id);
    _id = null;
    _noValida = false;
    notifyListeners();
  }

  /// The current photo now belongs to a saved product.
  void confirmar() => _subidas.clear();

  @override
  void dispose() {
    _desechada = true;
    for (final id in _subidas) {
      unawaited(_fotos.borrar(id));
    }
    super.dispose();
  }

  void _soltar(String? id) {
    if (id != null && _subidas.remove(id)) unawaited(_fotos.borrar(id));
  }
}
