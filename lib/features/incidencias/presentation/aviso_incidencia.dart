import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/presentation/textos_incidencia.dart';

/// "Incidencia registrada · Distribuidora 1 · Queso −2 piezas · 1,6 kg".
void mostrarIncidenciaRegistrada(
  ScaffoldMessengerState mensajero,
  ControladorIncidencias incidencias,
  Incidencia incidencia,
) {
  final afectado = incidencia.sacada
      ? ' −${textoAfectado(incidencia)}'
      : ' · ${textoAfectado(incidencia)} (sin tocar el inventario)';
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Incidencia registrada · ${incidencia.proveedor} · '
          '${incidencia.producto}$afectado',
        ),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(_deshacer(mensajero, incidencias)),
        ),
      ),
    );
}

Future<void> _deshacer(
  ScaffoldMessengerState mensajero,
  ControladorIncidencias incidencias,
) async {
  final deshecha = await incidencias.deshacer();
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          deshecha
              ? 'Incidencia deshecha'
              : 'No se pudo deshacer: el producto cambió después',
        ),
      ),
    );
}

/// Records the answer and offers to put the previous one back.
Future<void> responderIncidencia(
  ScaffoldMessengerState mensajero,
  ControladorIncidencias incidencias,
  Incidencia incidencia,
  RespuestaProveedor? respuesta,
) async {
  final anterior = incidencia.respuesta;
  await incidencias.responder(incidencia, respuesta);
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          respuesta == null
              ? 'Incidencia reabierta · ${incidencia.producto}'
              : 'Resuelta · ${incidencia.producto}: ${respuesta.etiqueta}',
        ),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => unawaited(
            incidencias.responder(incidencia.conRespuesta(respuesta), anterior),
          ),
        ),
      ),
    );
}
