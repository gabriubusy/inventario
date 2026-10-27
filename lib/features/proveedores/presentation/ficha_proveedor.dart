import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/presentation/seccion_incidencias.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';
import 'package:inventario/features/proveedores/presentation/dato_proveedor.dart';
import 'package:inventario/features/proveedores/presentation/tabla_suministros.dart';

class FichaProveedor extends StatelessWidget {
  const FichaProveedor({
    super.key,
    required this.proveedor,
    required this.suministros,
    required this.onEditar,
    required this.onRegistrarEntrada,
    required this.incidencias,
    required this.hoy,
    required this.onRegistrarIncidencia,
    required this.onResponder,
    this.deuda = 0,
  });

  final Proveedor proveedor;
  final List<Suministro> suministros;
  final VoidCallback onEditar;
  final VoidCallback onRegistrarEntrada;

  /// This supplier's incidents, newest first.
  final List<Incidencia> incidencias;
  final DateTime hoy;
  final VoidCallback onRegistrarIncidencia;
  final void Function(Incidencia, RespuestaProveedor?) onResponder;

  /// What is still owed to this supplier, in dollar hundredths.
  final int deuda;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final subtitulo = tema.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final vacio = tema.textTheme.bodyMedium?.copyWith(
      color: colores.onSurfaceVariant,
    );
    final marcas = marcasDe(suministros);
    return Card(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(espaciado.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.xl,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.md,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: espaciado.xs,
                    children: [
                      Text(
                        proveedor.nombre,
                        style: tema.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (proveedor.rif.isNotEmpty)
                        Text('RIF ${proveedor.rif}', style: vacio),
                    ],
                  ),
                ),
                // Buttons wrap to a second line before squeezing the name.
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: espaciado.sm,
                    runSpacing: espaciado.sm,
                    children: [
                      OutlinedButton(
                        onPressed: onEditar,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: espaciado.sm,
                          children: [
                            const Text('Editar'),
                            TeclaAtajo(
                              'Ctrl+E',
                              color: colores.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: onRegistrarIncidencia,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: espaciado.sm,
                          children: [
                            const Text('Incidencia'),
                            TeclaAtajo(
                              'Ctrl+I',
                              color: colores.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: onRegistrarEntrada,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: espaciado.sm,
                          children: [
                            const Text('Pedido a proveedor'),
                            TeclaAtajo('F2', color: colores.onPrimary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.md,
              children: [
                Expanded(
                  child: DatoProveedor(
                    etiqueta: 'Teléfono',
                    valor: proveedor.telefono,
                  ),
                ),
                Expanded(
                  child: DatoProveedor(
                    etiqueta: 'Persona de contacto',
                    valor: proveedor.contacto,
                  ),
                ),
                Expanded(
                  child: DatoProveedor(
                    etiqueta: 'Notas',
                    valor: proveedor.notas,
                  ),
                ),
              ],
            ),
            if (deuda > 0)
              Text(
                'Se le debe ${formatearDolares(deuda)} · ver en Cuentas (F10)',
                style: tema.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.coloresEstado.textoBajo,
                ),
              ),
            SeccionIncidencias(
              incidencias: incidencias,
              hoy: hoy,
              onResponder: onResponder,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.sm,
              children: [
                Text('Marcas que trae', style: subtitulo),
                if (marcas.isEmpty)
                  Text(
                    'Aparecen al crear productos o registrar entradas con este proveedor.',
                    style: vacio,
                  )
                else
                  Wrap(
                    spacing: espaciado.sm,
                    runSpacing: espaciado.sm,
                    children: [for (final marca in marcas) _Marca(marca)],
                  ),
              ],
            ),
            if (suministros.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.sm,
                children: [
                  Text('Productos que trae', style: subtitulo),
                  TablaSuministros(suministros: suministros),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca(this.nombre);

  final String nombre;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(espaciado.xxl),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.md,
          vertical: espaciado.xs + 2,
        ),
        child: Text(nombre, style: tema.textTheme.labelLarge),
      ),
    );
  }
}
