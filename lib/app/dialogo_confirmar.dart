import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';

/// Asks before a delicate action that can't be undone (the spec keeps
/// confirmations only for these). Enter does it, Esc doesn't.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String accion,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) =>
          DialogoConfirmar(titulo: titulo, mensaje: mensaje, accion: accion),
    ) ??
    false;

class DialogoConfirmar extends StatelessWidget {
  const DialogoConfirmar({
    super.key,
    required this.titulo,
    required this.mensaje,
    required this.accion,
  });

  static const _ancho = 480.0;
  static const _altoBoton = 50.0;

  final String titulo;
  final String mensaje;

  /// The button's text, e.g. "Borrar producto".
  final String accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _ancho),
        child: Padding(
          padding: EdgeInsets.all(espaciado.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: espaciado.lg,
            children: [
              Text(
                titulo,
                style: tema.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(mensaje, style: tema.textTheme.bodyMedium),
              Row(
                spacing: espaciado.md,
                children: [
                  Expanded(
                    child: FilledButton(
                      autofocus: true,
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.coloresEstado.textoAgotado,
                        minimumSize: const Size.fromHeight(_altoBoton),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: espaciado.sm,
                        children: [
                          Flexible(
                            child: Text(
                              accion,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TeclaAtajo('Enter', color: colores.onPrimary),
                        ],
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, _altoBoton),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: espaciado.sm,
                      children: [
                        const Text('No'),
                        TeclaAtajo('Esc', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
