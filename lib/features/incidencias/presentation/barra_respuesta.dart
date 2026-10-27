import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';

/// Under the chosen incident: how the supplier answered, or reopen it.
class BarraRespuesta extends StatelessWidget {
  const BarraRespuesta({
    super.key,
    required this.incidencia,
    required this.onResponder,
    this.conAtajos = false,
  });

  final Incidencia incidencia;

  /// Null reopens the incident.
  final ValueChanged<RespuestaProveedor?> onResponder;

  /// Shows Alt+1… next to each answer where the screen handles them.
  final bool conAtajos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final respuesta = incidencia.respuesta;
    final titulo = '${incidencia.producto} · ${incidencia.marca}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.surface,
        border: Border.all(color: colores.primary),
        borderRadius: BorderRadius.circular(espaciado.md),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.lg,
          vertical: espaciado.md,
        ),
        child: Wrap(
          spacing: espaciado.sm,
          runSpacing: espaciado.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: espaciado.sm),
              child: Text(
                respuesta == null
                    ? '$titulo — ¿cómo respondió el proveedor?'
                    : '$titulo — respondió: ${respuesta.etiqueta}',
                style: tema.textTheme.bodyMedium,
              ),
            ),
            if (respuesta == null)
              for (final (i, opcion) in RespuestaProveedor.values.indexed)
                OutlinedButton(
                  onPressed: () => onResponder(opcion),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: espaciado.sm,
                    children: [
                      Text(opcion.etiqueta),
                      if (conAtajos)
                        TeclaAtajo(
                          'Alt+${i + 1}',
                          color: colores.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
            if (respuesta != null)
              TextButton(
                onPressed: () => onResponder(null),
                child: const Text('Reabrir'),
              ),
          ],
        ),
      ),
    );
  }
}
