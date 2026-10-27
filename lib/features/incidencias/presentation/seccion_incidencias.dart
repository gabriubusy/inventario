import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/presentation/barra_respuesta.dart';
import 'package:inventario/features/incidencias/presentation/tabla_incidencias.dart';

/// "Incidencias" in a supplier's card; clicking one shows how to answer it.
class SeccionIncidencias extends StatefulWidget {
  const SeccionIncidencias({
    super.key,
    required this.incidencias,
    required this.hoy,
    required this.onResponder,
  });

  final List<Incidencia> incidencias;
  final DateTime hoy;
  final void Function(Incidencia, RespuestaProveedor?) onResponder;

  @override
  State<SeccionIncidencias> createState() => _SeccionIncidenciasState();
}

class _SeccionIncidenciasState extends State<SeccionIncidencias> {
  String? _elegidaId;

  Incidencia? get _elegida {
    for (final incidencia in widget.incidencias) {
      if (incidencia.id == _elegidaId) return incidencia;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final suave = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final incidencias = widget.incidencias;
    final abiertas = incidencias.where((i) => i.abierta).length;
    final elegida = _elegida;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.sm,
      children: [
        Row(
          spacing: espaciado.md,
          children: [
            Expanded(
              child: Text(
                'Incidencias',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (incidencias.isNotEmpty)
              Text(
                '${incidencias.length} en total · $abiertas '
                '${abiertas == 1 ? 'abierta' : 'abiertas'}',
                style: suave,
              ),
          ],
        ),
        if (incidencias.isEmpty)
          Text(
            'Sin incidencias. Si llega algo malo, regístralo con Ctrl+I.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          TablaIncidencias(
            incidencias: incidencias,
            hoy: widget.hoy,
            elegidaId: elegida?.id,
            mostrarProveedor: false,
            onElegir: (i) =>
                setState(() => _elegidaId = i.id == _elegidaId ? null : i.id),
          ),
          if (elegida != null)
            BarraRespuesta(
              incidencia: elegida,
              onResponder: (respuesta) =>
                  widget.onResponder(elegida, respuesta),
            )
          else
            Text('Haz clic en una para decir cómo respondió', style: suave),
        ],
      ],
    );
  }
}
