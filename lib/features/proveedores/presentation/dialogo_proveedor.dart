import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/botones_crear.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

/// Opens the window to create a supplier, or to edit [proveedor] if given.
Future<void> mostrarDialogoProveedor(
  BuildContext context,
  ControladorProveedores controlador, {
  Proveedor? proveedor,
}) => showDialog<void>(
  context: context,
  builder: (_) =>
      DialogoProveedor(controlador: controlador, proveedor: proveedor),
);

class DialogoProveedor extends StatefulWidget {
  const DialogoProveedor({
    super.key,
    required this.controlador,
    this.proveedor,
  });

  static const _ancho = 560.0;

  final ControladorProveedores controlador;

  /// Null when creating a new one.
  final Proveedor? proveedor;

  @override
  State<DialogoProveedor> createState() => _DialogoProveedorState();
}

class _DialogoProveedorState extends State<DialogoProveedor> {
  final _formulario = GlobalKey<FormState>();
  final _campoNombre = GlobalKey<FormFieldState<String>>();
  late final _nombre = TextEditingController(text: widget.proveedor?.nombre);
  late final _rif = TextEditingController(text: widget.proveedor?.rif);
  late final _telefono = TextEditingController(
    text: widget.proveedor?.telefono,
  );
  late final _contacto = TextEditingController(
    text: widget.proveedor?.contacto,
  );
  late final _notas = TextEditingController(text: widget.proveedor?.notas);
  final _focoNombre = FocusNode();
  var _guardando = false;
  var _repetido = false;

  bool get _editando => widget.proveedor != null;

  @override
  void dispose() {
    for (final c in [_nombre, _rif, _telefono, _contacto, _notas]) {
      c.dispose();
    }
    _focoNombre.dispose();
    super.dispose();
  }

  String? _validarNombre(String? texto) {
    if (texto == null || texto.trim().isEmpty) return 'Escribe el nombre';
    if (_repetido) return 'Ya existe un proveedor con ese nombre';
    return null;
  }

  void _nombreCambiado(String _) {
    if (!_repetido) return;
    _repetido = false;
    _campoNombre.currentState?.validate();
  }

  Future<void> _guardar({required bool otro}) async {
    if (_guardando || !(_formulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final datos = DatosProveedor(
      nombre: _nombre.text.trim(),
      rif: _rif.text.trim(),
      telefono: _telefono.text.trim(),
      contacto: _contacto.text.trim(),
      notas: _notas.text.trim(),
    );
    final anterior = widget.proveedor;
    final resultado = anterior == null
        ? await widget.controlador.crear(datos)
        : await widget.controlador.actualizar(anterior, datos);
    if (!mounted) return;
    setState(() => _guardando = false);
    switch (resultado) {
      case ProveedorGuardado(:final proveedor):
        final accion = _editando ? 'guardado' : 'creado';
        mensajero
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Proveedor $accion · ${proveedor.nombre}')),
          );
        if (otro) {
          _formulario.currentState?.reset();
          _focoNombre.requestFocus();
        } else {
          navegador.pop();
        }
      case NombreProveedorRepetido():
        _repetido = true;
        _campoNombre.currentState?.validate();
        _focoNombre.requestFocus();
    }
  }

  // Ctrl+Enter also submits the field; the shortcut already handles it.
  void _enterEnUltimo() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    unawaited(_guardar(otro: false));
  }

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    final tema = Theme.of(context);
    final crearOtro = _editando ? null : () => unawaited(_guardar(otro: true));
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.all(espaciado.xl),
      child: AtajosDeTeclado(
        atajos: {
          if (crearOtro != null) ...{
            const SingleActivator(LogicalKeyboardKey.enter, control: true):
                crearOtro,
            const SingleActivator(
              LogicalKeyboardKey.numpadEnter,
              control: true,
            ): crearOtro,
          },
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DialogoProveedor._ancho),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(espaciado.xl),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: espaciado.lg,
                children: [
                  EncabezadoDialogo(
                    titulo: _editando ? 'Editar proveedor' : 'Nuevo proveedor',
                    icono: Icons.local_shipping_outlined,
                  ),
                  TextFormField(
                    key: _campoNombre,
                    controller: _nombre,
                    focusNode: _focoNombre,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: _validarNombre,
                    onChanged: _nombreCambiado,
                  ),
                  Row(
                    spacing: espaciado.md,
                    children: [
                      Expanded(
                        child: _Campo(
                          controller: _rif,
                          etiqueta: 'RIF (opcional)',
                          pista: 'J-00000000-0',
                        ),
                      ),
                      Expanded(
                        child: _Campo(
                          controller: _telefono,
                          etiqueta: 'Teléfono',
                          pista: '0414-000.00.00',
                          teclado: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  _Campo(
                    controller: _contacto,
                    etiqueta: 'Persona de contacto (opcional)',
                  ),
                  _Campo(
                    controller: _notas,
                    etiqueta: 'Notas (opcional)',
                    pista: 'Días de visita, forma de pago…',
                    onSubmitted: _enterEnUltimo,
                  ),
                  if (!_editando)
                    Text(
                      'Las marcas y productos del proveedor se llenan solos '
                      'al crear productos o registrar entradas con él.',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  BotonesCrear(
                    etiqueta: _editando ? 'Guardar' : 'Crear',
                    guardando: _guardando,
                    onCrear: () => unawaited(_guardar(otro: false)),
                    onCrearOtro: crearOtro,
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

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controller,
    required this.etiqueta,
    this.pista,
    this.teclado,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? pista;
  final TextInputType? teclado;

  /// Without it, Enter just moves to the next field.
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final onSubmitted = this.onSubmitted;
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      decoration: InputDecoration(labelText: etiqueta, hintText: pista),
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
    );
  }
}
