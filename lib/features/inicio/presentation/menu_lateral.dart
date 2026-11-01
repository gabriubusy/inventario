import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/logo_inventario.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/inicio/presentation/enlaces_cabecera.dart';

/// Side menu opened from the header's hamburger button, with every
/// screen of the app and its shortcut.
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key, required this.enlaces});

  final List<EnlaceCabecera> enlaces;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    return Drawer(
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(espaciado.xl),
              child: Row(
                spacing: espaciado.md,
                children: [
                  LogoInventario(tamano: espaciado.xl + espaciado.lg),
                  Text(
                    'Inventario',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: espaciado.sm),
                children: [
                  for (final enlace in enlaces) _EntradaMenu(enlace: enlace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntradaMenu extends StatelessWidget {
  const _EntradaMenu({required this.enlace});

  final EnlaceCabecera enlace;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: espaciado.xl),
      title: Text(enlace.texto),
      trailing: TeclaAtajo(
        enlace.atajo,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      // Closes the menu first so the action opens over the home screen.
      onTap: () {
        Navigator.of(context).pop();
        enlace.onPressed();
      },
    );
  }
}
