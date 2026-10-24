import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/inicio/presentation/accion_rapida.dart';
import 'package:inventario/features/inicio/presentation/tecla_atajo.dart';

class BotonAccion extends StatelessWidget {
  const BotonAccion({super.key, required this.accion, required this.onPulsar});

  static const _alto = 116.0;

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
    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(accion.icono, color: destacada ? texto : colores.primary),
            const Spacer(),
            TeclaAtajo(accion.atajo, color: secundario),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              accion.titulo,
              style: tema.textTheme.titleMedium?.copyWith(
                color: texto,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              accion.descripcion,
              style: tema.textTheme.bodySmall?.copyWith(color: secundario),
            ),
          ],
        ),
      ],
    );
    final estilo = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(_alto)),
      padding: WidgetStatePropertyAll(EdgeInsets.all(espaciado.xl - 4)),
      alignment: Alignment.topLeft,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(espaciado.md),
        ),
      ),
    );
    return Tooltip(
      message: '${accion.titulo} (${accion.atajo})',
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
