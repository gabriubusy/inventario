import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

typedef EnlaceCabecera = ({String texto, String atajo, VoidCallback onPressed});

/// The header links side by side, or folded into a "Menú" when [compacto],
/// so they never shrink into unreadable text. Each keeps its shortcut.
class EnlacesCabecera extends StatelessWidget {
  const EnlacesCabecera({
    super.key,
    required this.enlaces,
    required this.compacto,
    this.fijos = 0,
  });

  final List<EnlaceCabecera> enlaces;
  final bool compacto;

  /// How many of the first links stay in view when [compacto], so the
  /// daily ones (the till) never hide in the menu.
  final int fijos;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    if (!compacto) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: espaciado.sm,
        children: [
          for (final enlace in enlaces)
            TextButton(
              onPressed: enlace.onPressed,
              child: _TextoConAtajo(enlace: enlace),
            ),
        ],
      );
    }
    final visibles = enlaces.take(fijos).toList();
    final menu = PopupMenuButton<VoidCallback>(
      tooltip: 'Más opciones',
      position: PopupMenuPosition.under,
      onSelected: (accion) => accion(),
      itemBuilder: (_) => [
        for (final enlace in enlaces.skip(fijos))
          PopupMenuItem(
            value: enlace.onPressed,
            child: _TextoConAtajo(enlace: enlace, separado: true),
          ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: espaciado.sm,
          children: [
            Icon(Icons.menu, color: colores.primary),
            Text('Menú', style: TextStyle(color: colores.primary)),
          ],
        ),
      ),
    );
    if (visibles.isEmpty) return menu;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: espaciado.sm,
      children: [
        for (final enlace in visibles)
          TextButton(
            onPressed: enlace.onPressed,
            child: _TextoConAtajo(enlace: enlace),
          ),
        menu,
      ],
    );
  }
}

class _TextoConAtajo extends StatelessWidget {
  const _TextoConAtajo({required this.enlace, this.separado = false});

  static const _anchoMenu = 220.0;

  final EnlaceCabecera enlace;

  /// In the menu the shortcut goes to the right edge, aligned in a column.
  final bool separado;

  @override
  Widget build(BuildContext context) {
    final atajo = TeclaAtajo(
      enlace.atajo,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    if (separado) {
      return SizedBox(
        width: _anchoMenu,
        child: Row(
          children: [
            Expanded(child: Text(enlace.texto)),
            atajo,
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.espaciado.sm,
      children: [Text(enlace.texto), atajo],
    );
  }
}
