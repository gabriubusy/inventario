import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/respaldo/application/controlador_respaldo.dart';
import 'package:inventario/features/respaldo/presentation/acciones_respaldo.dart';

/// Configuración's backup block: when the last one was, the folder, how
/// often to remind, "Respaldar ahora" and "Restaurar un respaldo…".
class SeccionRespaldo extends StatelessWidget {
  const SeccionRespaldo({
    super.key,
    required this.respaldo,
    this.elegirCarpeta = elegirCarpetaDelEquipo,
    this.elegirArchivo = elegirRespaldoDelEquipo,
  });

  static const _diasPosibles = [3, 7, 15, 30];
  static const _anchoDias = 180.0;
  static const _anchoCarpeta = 420.0;

  final ControladorRespaldo respaldo;
  final ElegirCarpeta elegirCarpeta;
  final ElegirArchivoRespaldo elegirArchivo;

  Future<void> _cambiarCarpeta() async {
    final carpeta = await elegirCarpeta();
    if (carpeta != null) await respaldo.cambiarCarpeta(carpeta);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final alertas = context.coloresEstado;
    final espaciado = context.espaciado;
    return ListenableBuilder(
      listenable: respaldo,
      builder: (context, _) {
        final ajustes = respaldo.ajustes;
        final dias = respaldo.diasSinRespaldo;
        final atrasado = respaldo.hayQueRecordar;
        if (!respaldo.disponible) {
          return Text(
            'El respaldo solo funciona en la app de Windows; en el navegador '
            'los datos quedan en el propio navegador.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: colores.onSurfaceVariant,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.md,
          children: [
            Wrap(
              spacing: espaciado.md,
              runSpacing: espaciado.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  backgroundColor: atrasado
                      ? alertas.fondoBajo
                      : alertas.fondoBien,
                  label: Text(
                    dias == null
                        ? 'Nunca se ha respaldado'
                        : dias == 0
                        ? 'Último: hoy'
                        : 'Último: hace $dias ${dias == 1 ? 'día' : 'días'}',
                    style: TextStyle(
                      color: atrasado ? alertas.textoBajo : alertas.textoBien,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Copia todo (productos, ventas, caja y fotos) en un '
                  'archivo .inventario, por ejemplo en un pendrive.',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: espaciado.md,
              runSpacing: espaciado.md,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: _anchoCarpeta,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Carpeta'),
                    child: Row(
                      spacing: espaciado.md,
                      children: [
                        Expanded(
                          child: Text(
                            ajustes.carpeta ?? 'Sin elegir',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () => unawaited(_cambiarCarpeta()),
                          child: const Text('Cambiar…'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: _anchoDias,
                  child: DropdownButtonFormField<int>(
                    initialValue: ajustes.diasRecordatorio,
                    decoration: const InputDecoration(
                      labelText: 'Recordar cada',
                    ),
                    items: [
                      for (final d in {
                        ..._diasPosibles,
                        ajustes.diasRecordatorio,
                      })
                        DropdownMenuItem(value: d, child: Text('$d días')),
                    ],
                    onChanged: (d) {
                      if (d != null) unawaited(respaldo.cambiarDias(d));
                    },
                  ),
                ),
                FilledButton(
                  // The theme stretches filled buttons; this one sits in a row.
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: () => unawaited(
                    respaldarAhora(context, respaldo, elegir: elegirCarpeta),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: espaciado.sm,
                    children: [
                      const Text('Respaldar ahora'),
                      TeclaAtajo('Ctrl+B', color: colores.onPrimary),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Cambiaste de computadora o se dañó el disco?',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: colores.onSurfaceVariant,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => unawaited(
                    restaurarRespaldo(context, respaldo, elegir: elegirArchivo),
                  ),
                  child: const Text('Restaurar un respaldo…'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
