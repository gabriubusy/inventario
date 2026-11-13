import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/rejilla_adaptable.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/texto.dart';
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
    this.onDevolver,
    this.onQuitarMarca,
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

  /// Ctrl+D: sends goods back to this supplier; hidden when null.
  final VoidCallback? onDevolver;

  /// Takes a brand off this supplier's products; no cross is shown
  /// without it.
  final ValueChanged<String>? onQuitarMarca;

  /// What is still owed to this supplier, in dollar hundredths.
  final int deuda;

  static const _anchoDato = 160.0;

  /// Stock left of a brand: then it is not taken off the supplier.
  bool _conExistencias(String marca) {
    final cual = normalizarParaBusqueda(marca);
    return suministros.any(
      (s) =>
          normalizarParaBusqueda(s.lote.marca) == cual &&
          s.lote.tieneExistencia,
    );
  }

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
    final onDevolver = this.onDevolver;
    return Card(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(espaciado.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: espaciado.xl,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.md,
              children: [
                Column(
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
                // Under the name, so a narrow sheet never squeezes either.
                Wrap(
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
                          TeclaAtajo('Ctrl+E', color: colores.onSurfaceVariant),
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
                          TeclaAtajo('Ctrl+I', color: colores.onSurfaceVariant),
                        ],
                      ),
                    ),
                    if (onDevolver != null)
                      OutlinedButton(
                        onPressed: onDevolver,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: espaciado.sm,
                          children: [
                            const Text('Devolver'),
                            TeclaAtajo(
                              'Ctrl+D',
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
              ],
            ),
            RejillaAdaptable(
              anchoMinimo: _anchoDato,
              espacio: espaciado.md,
              children: [
                DatoProveedor(etiqueta: 'Teléfono', valor: proveedor.telefono),
                DatoProveedor(
                  etiqueta: 'Persona de contacto',
                  valor: proveedor.contacto,
                ),
                DatoProveedor(etiqueta: 'Notas', valor: proveedor.notas),
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
                    children: [
                      for (final marca in marcas)
                        _Marca(
                          nombre: marca,
                          conExistencias: _conExistencias(marca),
                          onQuitar: onQuitarMarca,
                        ),
                    ],
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
  const _Marca({
    required this.nombre,
    required this.conExistencias,
    this.onQuitar,
  });

  static const _tamanoQuitar = 16.0;

  final String nombre;

  /// Stock left, so the brand cannot be taken off yet.
  final bool conExistencias;

  final ValueChanged<String>? onQuitar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final onQuitar = this.onQuitar;
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: espaciado.xs,
          children: [
            Text(nombre, style: tema.textTheme.labelLarge),
            if (onQuitar != null)
              // Out of the focus order: the card is walked with the arrows.
              ExcludeFocus(
                child: IconButton(
                  onPressed: conExistencias ? null : () => onQuitar(nombre),
                  icon: const Icon(Icons.close),
                  iconSize: _tamanoQuitar,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  tooltip: conExistencias
                      ? 'Queda stock de $nombre: sale con ventas, mermas o '
                            'Conteo (F9)'
                      : 'Quitar $nombre de los productos de este proveedor',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
