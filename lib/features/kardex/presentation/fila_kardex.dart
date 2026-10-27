import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/kardex/domain/linea_kardex.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/movimientos/presentation/textos_movimiento.dart';

/// Column widths shared by the kardex header and its rows.
class ColumnasKardex extends StatelessWidget {
  const ColumnasKardex({
    super.key,
    required this.fecha,
    required this.tipo,
    required this.detalle,
    required this.entra,
    required this.sale,
    required this.saldo,
  });

  static const _anchoFecha = 110.0;
  static const _anchoTipo = 110.0;
  static const _anchoCifra = 100.0;

  final Widget fecha;
  final Widget tipo;
  final Widget detalle;
  final Widget entra;
  final Widget sale;
  final Widget saldo;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.espaciado.md,
      children: [
        SizedBox(width: _anchoFecha, child: fecha),
        SizedBox(width: _anchoTipo, child: tipo),
        Expanded(child: detalle),
        SizedBox(width: _anchoCifra, child: entra),
        SizedBox(width: _anchoCifra, child: sale),
        SizedBox(width: _anchoCifra, child: saldo),
      ],
    );
  }
}

class FilaKardex extends StatelessWidget {
  const FilaKardex({
    super.key,
    required this.linea,
    required this.unidad,
    required this.hoy,
  });

  final LineaKardex linea;
  final UnidadBase unidad;
  final DateTime hoy;

  String get _detalle {
    final m = linea.movimiento;
    final partes = [
      m.marca,
      if (m.proveedor.isNotEmpty && m.tipo == TipoMovimiento.entrada)
        m.proveedor,
      if (m.nota.isNotEmpty) m.nota,
    ];
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final m = linea.movimiento;
    const cifras = [FontFeature.tabularFigures()];
    final base = tema.textTheme.bodyMedium?.copyWith(fontFeatures: cifras);
    final fuerte = base?.copyWith(fontWeight: FontWeight.w600);
    final tinta = switch (m.tipo.grupo) {
      GrupoMovimiento.ventas => colores.primary,
      GrupoMovimiento.entradas => colores.tertiary,
      GrupoMovimiento.perdidas => context.coloresEstado.textoBajo,
    };
    String cifra(int n) => n == 0 ? '' : unidad.formatear(n);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colores.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.lg,
          vertical: espaciado.sm + 2,
        ),
        child: ColumnasKardex(
          fecha: Text(
            '${formatearFechaCorta(m.fecha, hoy)} ${textoHora(m.fecha)}',
            style: base?.copyWith(color: colores.onSurfaceVariant),
          ),
          tipo: Text(
            m.tipo.etiqueta.toUpperCase(),
            style: tema.textTheme.labelSmall?.copyWith(
              color: tinta,
              fontWeight: FontWeight.w600,
            ),
          ),
          detalle: Text(
            _detalle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: base,
          ),
          entra: Text(
            cifra(linea.entra),
            textAlign: TextAlign.right,
            style: fuerte?.copyWith(color: colores.tertiary),
          ),
          sale: Text(
            cifra(linea.sale),
            textAlign: TextAlign.right,
            style: fuerte,
          ),
          saldo: Text(
            unidad.formatear(linea.saldo),
            textAlign: TextAlign.right,
            style: fuerte,
          ),
        ),
      ),
    );
  }
}
