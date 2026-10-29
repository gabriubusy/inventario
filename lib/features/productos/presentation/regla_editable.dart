import 'package:flutter/widgets.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/domain/regla_precio.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';

/// How a list other than Detal gets its price in the product form.
enum TipoRegla {
  ninguna('Sin regla'),
  margen('Costo + %'),
  fijo('Precio fijo');

  const TipoRegla(this.etiqueta);

  final String etiqueta;
}

/// The kind and value of one list's rule while the form is open.
class ReglaEditable {
  ReglaEditable.desde(ReglaPrecio? regla)
    : tipo = switch (regla) {
        null => TipoRegla.ninguna,
        MargenSobreCosto() => TipoRegla.margen,
        PrecioFijo() => TipoRegla.fijo,
      } {
    valor.text = switch (regla) {
      null => '',
      MargenSobreCosto(:final porcentaje) => formatDecimal(
        porcentaje,
        decimales: _decimales,
      ),
      PrecioFijo(:final precio) => formatDecimal(
        precio,
        decimales: decimalesDinero,
        minDecimales: decimalesDinero,
      ),
    };
  }

  // Percent in hundredths, like money.
  static const _decimales = 2;

  TipoRegla tipo;
  final valor = TextEditingController();
  final foco = FocusNode();

  /// Null for no rule, or for a rule left without a value.
  ReglaPrecio? leer() {
    if (valor.text.trim().isEmpty) return null;
    final numero = CampoCantidad.leer(valor, _decimales);
    return switch (tipo) {
      TipoRegla.ninguna => null,
      TipoRegla.margen => MargenSobreCosto(numero),
      TipoRegla.fijo => PrecioFijo(numero),
    };
  }

  void limpiar() {
    tipo = TipoRegla.ninguna;
    valor.clear();
  }

  void dispose() {
    valor.dispose();
    foco.dispose();
  }
}
