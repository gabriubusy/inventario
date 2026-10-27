import 'package:flutter/widgets.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';

/// Text controllers of one pack row in the product form.
class PresentacionEditable {
  PresentacionEditable();

  PresentacionEditable.desde(Presentacion presentacion, FormaConteo forma) {
    predeterminada = presentacion.predeterminada;
    nombre.text = presentacion.nombre;
    contiene.text = formatDecimal(
      presentacion.factor,
      decimales: forma.unidad.decimales,
    );
    codigo.text = presentacion.codigo;
    precio.text = formatDecimal(
      presentacion.precio,
      decimales: decimalesDinero,
      minDecimales: decimalesDinero,
    );
  }

  final nombre = TextEditingController();
  final contiene = TextEditingController();
  final codigo = TextEditingController();
  final precio = TextEditingController();
  final focoNombre = FocusNode();
  bool predeterminada = false;

  List<TextEditingController> get _campos => [nombre, contiene, codigo, precio];

  /// An untouched row is skipped instead of failing validation.
  bool get vacio => _campos.every((c) => c.text.trim().isEmpty);

  String get claveCodigo =>
      normalizarParaBusqueda(codigo.text).replaceAll(' ', '');

  Presentacion leer(FormaConteo forma, {required bool predeterminada}) =>
      Presentacion(
        nombre: nombre.text.trim(),
        factor: CampoCantidad.leer(contiene, forma.unidad.decimales),
        precio: CampoCantidad.leer(precio, decimalesDinero),
        codigo: codigo.text.trim(),
        predeterminada: predeterminada,
      );

  void dispose() {
    for (final campo in _campos) {
      campo.dispose();
    }
    focoNombre.dispose();
  }
}
