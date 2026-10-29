import 'package:flutter/widgets.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';
import 'package:inventario/features/productos/presentation/regla_editable.dart';

/// The Mayor and Especial rules of the product form; Detal is the brand
/// price itself.
class ReglasEditables extends ChangeNotifier {
  ReglasEditables.desde(Producto? producto)
    : filas = {
        for (final lista in ListaPrecio.conRegla)
          lista: ReglaEditable.desde(producto?.reglas[lista]),
      },
      _abierta = producto?.reglas.isNotEmpty ?? false;

  final Map<ListaPrecio, ReglaEditable> filas;

  /// Folded to one line while no list has a rule, to keep the form short.
  bool get abierta => _abierta;
  bool _abierta;

  void abrir() {
    _abierta = true;
    notifyListeners();
  }

  Listenable get cambios =>
      Listenable.merge([this, for (final f in filas.values) f.valor]);

  void elegir(ListaPrecio lista, TipoRegla tipo) {
    final fila = filas[lista]!;
    fila.tipo = tipo;
    notifyListeners();
    if (tipo == TipoRegla.ninguna) return;
    // The field only exists from the next frame on.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => fila.foco.requestFocus(),
    );
  }

  /// Alt+L: to the first list's value, giving it a margin if it had none.
  void enfocar() {
    _abierta = true;
    final lista = ListaPrecio.conRegla.first;
    if (filas[lista]!.tipo == TipoRegla.ninguna) {
      elegir(lista, TipoRegla.margen);
    } else {
      filas[lista]!.foco.requestFocus();
    }
  }

  Map<ListaPrecio, ReglaPrecio> leer() => {
    for (final MapEntry(key: lista, value: fila) in filas.entries)
      lista: ?fila.leer(),
  };

  void limpiar() {
    for (final fila in filas.values) {
      fila.limpiar();
    }
    _abierta = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final fila in filas.values) {
      fila.dispose();
    }
    super.dispose();
  }
}
