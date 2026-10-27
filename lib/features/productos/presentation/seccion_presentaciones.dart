import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/fila_presentacion.dart';
import 'package:inventario/features/productos/presentation/presentaciones_editables.dart';

/// The fixed packs a product sells in (Saco = 15 kg, Kilo = 1 kg), each with
/// its own code and price. Not shown for products counted in pieces.
class SeccionPresentaciones extends StatelessWidget {
  const SeccionPresentaciones({
    super.key,
    required this.presentaciones,
    required this.forma,
    required this.codigoOcupado,
    this.existencias,
  });

  final PresentacionesEditables presentaciones;
  final FormaConteo forma;
  final bool Function(String codigo) codigoOcupado;

  /// "26,5 kg (1 saco + 11,5 kg)" when editing.
  final String? existencias;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final existencias = this.existencias;
    final nota = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
    );
    return ListenableBuilder(
      listenable: presentaciones,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: espaciado.sm,
        children: [
          Row(
            spacing: espaciado.md,
            children: [
              Text(
                'Presentaciones',
                style: tema.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  existencias == null
                      ? '(opcional) · ★ la que sale primero al vender'
                      : 'Hay $existencias',
                  style: nota,
                ),
              ),
            ],
          ),
          for (final fila in presentaciones.filas)
            FilaPresentacion(
              key: ObjectKey(fila),
              fila: fila,
              forma: forma,
              predeterminada: presentaciones.esPredeterminada(fila),
              codigoRepetido: () => presentaciones.codigoRepetido(fila),
              codigoOcupado: codigoOcupado,
              onMarcar: () => presentaciones.marcar(fila),
              onQuitar: () => presentaciones.quitar(fila),
            ),
          Row(
            children: [
              ExcludeFocus(
                child: TextButton.icon(
                  onPressed: presentaciones.agregar,
                  icon: const Icon(Icons.add),
                  label: Row(
                    spacing: espaciado.sm,
                    children: [
                      const Text('Otra presentación'),
                      TeclaAtajo('Ctrl+P', color: colores.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'El código se escribe o se lee con el lector de barras',
                  textAlign: TextAlign.right,
                  style: nota,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
