import 'package:flutter/material.dart';
import 'package:inventario/app/colores_estado.dart';
import 'package:inventario/features/productos/domain/estado_stock.dart';

typedef EstiloEstado = ({Color fondo, Color texto, Color barra});

EstiloEstado estiloDeEstado(BuildContext context, EstadoStock estado) {
  final alertas = context.coloresEstado;
  final colores = Theme.of(context).colorScheme;
  return switch (estado) {
    EstadoStock.agotado => (
      fondo: alertas.fondoAgotado,
      texto: alertas.textoAgotado,
      barra: alertas.barraAgotado,
    ),
    EstadoStock.bajo => (
      fondo: alertas.fondoBajo,
      texto: alertas.textoBajo,
      barra: alertas.barraBajo,
    ),
    EstadoStock.disponible => (
      fondo: colores.surfaceContainerHighest,
      texto: colores.onSurfaceVariant,
      barra: colores.onSurfaceVariant,
    ),
  };
}
