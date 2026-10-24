import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';
import 'package:inventario/features/productos/presentation/estilo_estado.dart';

class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado(this.estado, {super.key});

  final EstadoStock estado;

  @override
  Widget build(BuildContext context) {
    final estilo = estiloDeEstado(context, estado);
    final espaciado = context.espaciado;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(espaciado.xxl),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: espaciado.sm,
          vertical: espaciado.xs / 2,
        ),
        child: Text(
          estado.etiqueta,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: estilo.texto, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
