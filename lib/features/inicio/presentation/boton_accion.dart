import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';

/// A low button: icon, action and its key, so the day's figures fit above
/// the fold.
class BotonAccion extends StatelessWidget {
  const BotonAccion({super.key, required this.accion, required this.onPulsar});

  static const _alto = 56.0;

  final AccionRapida accion;
  final VoidCallback onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final destacada = accion.destacada;
    final texto = destacada ? colores.onPrimary : colores.onSurface;
    final secundario = destacada
        ? colores.onPrimary.withValues(alpha: 0.85)
        : colores.onSurfaceVariant;
    final contenido = Row(
      spacing: espaciado.md,
      children: [
        Icon(accion.icono, color: destacada ? texto : colores.primary),
        Expanded(
          child: Text(
            accion.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tema.textTheme.titleSmall?.copyWith(
              color: texto,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TeclaAtajo(accion.atajo, color: secundario),
      ],
    );
    final estilo = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(_alto)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: espaciado.lg),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(espaciado.md),
        ),
      ),
    );
    return Tooltip(
      message: accion.descripcion,
      child: destacada
          ? FilledButton(onPressed: onPulsar, style: estilo, child: contenido)
          : OutlinedButton(
              onPressed: onPulsar,
              style: estilo.copyWith(
                backgroundColor: WidgetStatePropertyAll(colores.surface),
              ),
              child: contenido,
            ),
    );
  }
}
