import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/domain/origen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:inventario/features/tasa/presentation/variacion_tasa.dart';

/// The dollar rate, always in sight: where it comes from, its value and how
/// much it moved since the previous one. Ctrl+T changes it.
class BotonTasa extends StatelessWidget {
  const BotonTasa({
    super.key,
    required this.controlador,
    required this.onPulsar,
  });

  final ControladorTasa controlador;
  final VoidCallback onPulsar;

  String _etiqueta(TasaCambio tasa) {
    if (!controlador.esDeHoy) return 'Última tasa';
    return tasa.origen == OrigenTasa.bcv ? 'BCV hoy' : 'Tasa de hoy';
  }

  String _ayuda(TasaCambio? tasa) {
    final anterior = tasa?.anterior;
    const cambiar = 'Ctrl+T para escribirla a mano';
    if (anterior == null) return cambiar;
    return 'Anterior: ${formatearBolivares(anterior)} · $cambiar';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final tasa = controlador.tasa;
    final variacion = tasa?.variacion;
    return Tooltip(
      message: _ayuda(tasa),
      child: OutlinedButton(
        onPressed: onPulsar,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: EdgeInsets.symmetric(horizontal: espaciado.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: espaciado.sm,
          children: [
            Icon(Icons.currency_exchange, size: 20, color: colores.primary),
            if (tasa == null)
              Text(controlador.consultando ? 'Consultando BCV…' : 'Poner tasa')
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _etiqueta(tasa),
                    style: tema.textTheme.labelSmall?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '1 \$ = ${formatearBolivares(tasa.bolivaresPorDolar)}',
                    style: tema.textTheme.titleSmall?.copyWith(
                      color: colores.onSurface,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            if (variacion != null) VariacionTasa(variacion),
            TeclaAtajo('Ctrl+T', color: colores.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
