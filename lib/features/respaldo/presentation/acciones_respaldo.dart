import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:inventario/app/dialogo_confirmar.dart';
import 'package:inventario/features/respaldo/application/controlador_respaldo.dart';
import 'package:inventario/features/respaldo/domain/archivo_respaldo.dart';
import 'package:inventario/features/respaldo/domain/resultado_respaldo.dart';

/// Asks for a folder; null when the user cancels. Injected so tests skip
/// the system dialog.
typedef ElegirCarpeta = Future<String?> Function();

/// Asks for a `.inventario` file; null when the user cancels.
typedef ElegirArchivoRespaldo = Future<String?> Function();

Future<String?> elegirCarpetaDelEquipo() =>
    getDirectoryPath(confirmButtonText: 'Usar esta carpeta');

Future<String?> elegirRespaldoDelEquipo() async => (await openFile(
  acceptedTypeGroups: const [
    XTypeGroup(label: 'Respaldo de Inventario', extensions: ['inventario']),
  ],
))?.path;

/// Ctrl+B: backs up into the saved folder, asking for one the first time.
Future<void> respaldarAhora(
  BuildContext context,
  ControladorRespaldo respaldo, {
  ElegirCarpeta elegir = elegirCarpetaDelEquipo,
}) async {
  final mensajero = ScaffoldMessenger.of(context);
  if (!respaldo.disponible) {
    _avisar(mensajero, 'El respaldo solo funciona en la app de Windows');
    return;
  }
  final carpeta = respaldo.ajustes.carpeta ?? await elegir();
  if (carpeta == null) return;
  final resultado = await respaldo.respaldar(carpeta: carpeta);
  switch (resultado) {
    case RespaldoGuardado(:final ruta, :final bytes):
      _avisar(mensajero, 'Respaldo guardado · $ruta · ${textoTamano(bytes)}');
    case CarpetaNoDisponible(:final carpeta):
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'No se encontró "$carpeta": ¿está conectado el pendrive?',
            ),
            persist: false,
            action: SnackBarAction(
              label: 'Elegir otra',
              onPressed: () =>
                  unawaited(_otraCarpeta(respaldo, mensajero, elegir)),
            ),
          ),
        );
    case RespaldoNoValido() ||
        RestauracionPreparada() ||
        RespaldoNoDisponibleAqui():
      _avisar(mensajero, 'No se pudo respaldar');
  }
}

Future<void> _otraCarpeta(
  ControladorRespaldo respaldo,
  ScaffoldMessengerState mensajero,
  ElegirCarpeta elegir,
) async {
  final carpeta = await elegir();
  if (carpeta == null) return;
  final resultado = await respaldo.respaldar(carpeta: carpeta);
  if (resultado case RespaldoGuardado(:final ruta, :final bytes)) {
    _avisar(mensajero, 'Respaldo guardado · $ruta · ${textoTamano(bytes)}');
  }
}

/// Picks a backup, asks before replacing everything, then closes the app
/// so the next start puts it in place.
Future<void> restaurarRespaldo(
  BuildContext context,
  ControladorRespaldo respaldo, {
  String? archivo,
  ElegirArchivoRespaldo elegir = elegirRespaldoDelEquipo,
}) async {
  final mensajero = ScaffoldMessenger.of(context);
  final ruta = archivo ?? await elegir();
  if (ruta == null || !context.mounted) return;
  final si = await confirmar(
    context,
    titulo: '¿Restaurar este respaldo?',
    mensaje:
        'Todo lo de ahora se reemplaza por lo del respaldo; lo registrado '
        'después de hacerlo se pierde. Antes se guarda una copia de lo de '
        'ahora en la misma carpeta, por si te equivocas. La app se cierra '
        'al terminar: ábrela otra vez.',
    accion: 'Restaurar',
  );
  if (!si) return;
  final resultado = await respaldo.prepararRestauracion(ruta);
  if (!context.mounted) return;
  switch (resultado) {
    case RestauracionPreparada(:final copiaDeAntes):
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (contexto) => AlertDialog(
          title: const Text('Listo para restaurar'),
          content: Text(
            'Se guardó una copia de lo de antes en:\n$copiaDeAntes\n\n'
            'La app se cerrará ahora. Al abrirla otra vez tendrá los datos '
            'del respaldo.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              autofocus: true,
              onPressed: respaldo.cerrarApp,
              child: const Text('Cerrar la app'),
            ),
          ],
        ),
      );
    case RespaldoNoValido():
      _avisar(mensajero, 'Ese archivo no es un respaldo de Inventario');
    case CarpetaNoDisponible() ||
        RespaldoGuardado() ||
        RespaldoNoDisponibleAqui():
      _avisar(mensajero, 'No se pudo preparar la restauración');
  }
}

void _avisar(ScaffoldMessengerState mensajero, String texto) => mensajero
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(texto)));
