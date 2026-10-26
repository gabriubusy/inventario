import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';

abstract final class TemaApp {
  static const _granate = Color(0xFF7A1F2B);
  static const _radio = BorderRadius.all(Radius.circular(8));
  static const _radioTarjeta = BorderRadius.all(Radius.circular(12));

  static ThemeData claro() {
    // Fidelity keeps the primary close to the brand burgundy.
    final colores = ColorScheme.fromSeed(
      seedColor: _granate,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    return ThemeData(
      colorScheme: colores,
      scaffoldBackgroundColor: colores.surfaceContainerLow,
      extensions: const [Espaciado.normal, ColoresEstado.normal],
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colores.surface,
        shape: RoundedRectangleBorder(
          borderRadius: _radioTarjeta,
          side: BorderSide(color: colores.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colores.surface,
        shape: RoundedRectangleBorder(
          borderRadius: _radioTarjeta,
          side: BorderSide(color: colores.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(borderRadius: _radio),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radio,
          borderSide: BorderSide(color: colores.outlineVariant),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: _radio),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colores.outlineVariant),
          ),
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: _radio),
          ),
        ),
      ),
    );
  }
}
