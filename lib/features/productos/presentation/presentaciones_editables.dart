import 'package:flutter/widgets.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/presentacion_editable.dart';

/// The pack rows of the product form. Exactly one is the default; when the
/// user marks none, the first one is.
class PresentacionesEditables extends ChangeNotifier {
  PresentacionesEditables.desde(Producto? producto)
    : filas = [
        for (final p in producto?.presentaciones ?? const <Presentacion>[])
          PresentacionEditable.desde(p, producto!.forma),
      ];

  final List<PresentacionEditable> filas;

  bool esPredeterminada(PresentacionEditable fila) {
    final enUso = filas.where((f) => !f.vacio).toList();
    final marcada = enUso.where((f) => f.predeterminada).firstOrNull;
    return fila == (marcada ?? enUso.firstOrNull);
  }

  /// The same code twice in this product would make a scan ambiguous.
  bool codigoRepetido(PresentacionEditable fila) {
    final clave = fila.claveCodigo;
    if (clave.isEmpty) return false;
    return filas
        .take(filas.indexOf(fila))
        .any((otra) => otra.claveCodigo == clave);
  }

  void agregar() {
    final fila = PresentacionEditable();
    filas.add(fila);
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => fila.focoNombre.requestFocus(),
    );
  }

  void quitar(PresentacionEditable fila) {
    filas.remove(fila);
    notifyListeners();
    // Still on screen this frame; dispose it afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) => fila.dispose());
  }

  void marcar(PresentacionEditable fila) {
    for (final f in filas) {
      f.predeterminada = f == fila;
    }
    notifyListeners();
  }

  List<Presentacion> leer(FormaConteo forma) => [
    for (final fila in filas)
      if (!fila.vacio) fila.leer(forma, predeterminada: esPredeterminada(fila)),
  ];

  void limpiar() {
    final quitadas = List.of(filas);
    filas.clear();
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final fila in quitadas) {
        fila.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (final fila in filas) {
      fila.dispose();
    }
    super.dispose();
  }
}
