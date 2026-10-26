import 'package:flutter/widgets.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';

/// Text controllers of one brand row in the product form.
class LoteEditable {
  LoteEditable() : original = null;

  /// Prefilled with a saved brand, whose stock is kept as it was.
  LoteEditable.desde(LoteMarca lote, FormaConteo forma) : original = lote {
    marca.text = lote.marca;
    proveedor.text = lote.proveedor;
    if (forma.cuentaPiezas) {
      piezas.text = formatDecimal(lote.piezas, decimales: 0);
    }
    cantidad.text = formatDecimal(
      lote.cantidad,
      decimales: forma.unidad.decimales,
    );
    if (lote.precio case final valor?) {
      precio.text = formatDecimal(
        valor,
        decimales: decimalesDinero,
        minDecimales: decimalesDinero,
      );
    }
  }

  /// The saved brand this row edits; null for a new row.
  final LoteMarca? original;

  final marca = TextEditingController();
  final proveedor = TextEditingController();
  final piezas = TextEditingController();
  final cantidad = TextEditingController();
  final precio = TextEditingController();
  final focoMarca = FocusNode();
  final focoProveedor = FocusNode();

  List<TextEditingController> get _campos => [
    marca,
    proveedor,
    piezas,
    cantidad,
    precio,
  ];

  Listenable get cambios => Listenable.merge(_campos);

  /// An untouched row is skipped instead of failing validation.
  bool get vacio => _campos.every((c) => c.text.trim().isEmpty);

  /// Rows with stock stay: the stock only changes with entries and sales.
  bool get tieneExistencia => original?.tieneExistencia ?? false;

  /// Brand and supplier together identify a row.
  String get clave =>
      '${normalizarParaBusqueda(marca.text)}|${normalizarParaBusqueda(proveedor.text)}';

  int leerPiezas() => CampoCantidad.leer(piezas, 0);

  int leerCantidad(FormaConteo forma) =>
      CampoCantidad.leer(cantidad, forma.unidad.decimales);

  /// Null when left empty: the brand simply has no price yet.
  int? leerPrecio() => precio.text.trim().isEmpty
      ? null
      : CampoCantidad.leer(precio, decimalesDinero);

  LoteMarca leer(FormaConteo forma) => LoteMarca(
    marca: marca.text.trim(),
    proveedor: proveedor.text.trim(),
    piezas: forma.cuentaPiezas ? leerPiezas() : 0,
    piezaAbierta: forma.cuentaPiezas && (original?.piezaAbierta ?? false),
    cantidad: leerCantidad(forma),
    precio: leerPrecio(),
  );

  void limpiar() {
    for (final campo in _campos) {
      campo.clear();
    }
  }

  void dispose() {
    for (final campo in _campos) {
      campo.dispose();
    }
    focoMarca.dispose();
    focoProveedor.dispose();
  }
}
