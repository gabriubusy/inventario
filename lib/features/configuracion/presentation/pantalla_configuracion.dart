import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/features/configuracion/application/controlador_negocio.dart';
import 'package:inventario/features/configuracion/domain/datos_negocio.dart';
import 'package:inventario/features/configuracion/presentation/bloque_configuracion.dart';
import 'package:inventario/features/configuracion/presentation/campos_negocio.dart';
import 'package:inventario/features/respaldo/application/controlador_respaldo.dart';
import 'package:inventario/features/respaldo/presentation/acciones_respaldo.dart';
import 'package:inventario/features/respaldo/presentation/seccion_respaldo.dart';

/// Ctrl+, from home (option A of "Fase 5 Inventario"): one page with the
/// shop's details, backups and the PIN. Ctrl+S saves, Ctrl+B backs up.
class PantallaConfiguracion extends StatefulWidget {
  const PantallaConfiguracion({
    super.key,
    required this.negocio,
    required this.respaldo,
    required this.onCambiarPin,
    this.elegirCarpeta = elegirCarpetaDelEquipo,
    this.elegirArchivo = elegirRespaldoDelEquipo,
  });

  static const _anchoMaximo = 900.0;

  final ControladorNegocio negocio;
  final ControladorRespaldo respaldo;
  final VoidCallback onCambiarPin;
  final ElegirCarpeta elegirCarpeta;
  final ElegirArchivoRespaldo elegirArchivo;

  @override
  State<PantallaConfiguracion> createState() => _PantallaConfiguracionState();
}

class _PantallaConfiguracionState extends State<PantallaConfiguracion> {
  late final _nombre = TextEditingController(text: widget.negocio.datos.nombre);
  late final _rif = TextEditingController(text: widget.negocio.datos.rif);
  late final _direccion = TextEditingController(
    text: widget.negocio.datos.direccion,
  );
  late final _telefono = TextEditingController(
    text: widget.negocio.datos.telefono,
  );

  @override
  void dispose() {
    for (final c in [_nombre, _rif, _direccion, _telefono]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final mensajero = ScaffoldMessenger.of(context);
    await widget.negocio.guardar(
      DatosNegocio(
        nombre: _nombre.text.trim(),
        rif: _rif.text.trim(),
        direccion: _direccion.text.trim(),
        telefono: _telefono.text.trim(),
      ),
    );
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Datos del negocio guardados')),
      );
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): () =>
        unawaited(Navigator.of(context).maybePop()),
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_guardar()),
    const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
        unawaited(
          respaldarAhora(
            context,
            widget.respaldo,
            elegir: widget.elegirCarpeta,
          ),
        ),
    const SingleActivator(LogicalKeyboardKey.keyL, control: true, shift: true):
        widget.onCambiarPin,
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: espaciado.xl),
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () => unawaited(_guardar()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: espaciado.sm,
                  children: [
                    const Text('Guardar'),
                    TeclaAtajo('Ctrl+S', color: colores.onPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(espaciado.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: PantallaConfiguracion._anchoMaximo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  BloqueConfiguracion(
                    titulo: 'Datos del negocio',
                    detalle: 'Salen en los PDF de reportes',
                    child: CamposNegocio(
                      nombre: _nombre,
                      rif: _rif,
                      direccion: _direccion,
                      telefono: _telefono,
                      onGuardar: () => unawaited(_guardar()),
                    ),
                  ),
                  BloqueConfiguracion(
                    titulo: 'Respaldo',
                    child: SeccionRespaldo(
                      respaldo: widget.respaldo,
                      elegirCarpeta: widget.elegirCarpeta,
                      elegirArchivo: widget.elegirArchivo,
                    ),
                  ),
                  BloqueConfiguracion(
                    titulo: 'PIN de acceso',
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: widget.onCambiarPin,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: espaciado.sm,
                          children: [
                            const Text('Cambiar PIN'),
                            TeclaAtajo(
                              'Ctrl+Shift+L',
                              color: colores.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
