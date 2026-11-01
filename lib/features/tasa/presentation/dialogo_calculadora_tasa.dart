import 'package:flutter/material.dart';
import 'package:inventario/app/encabezado_dialogo.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';

Future<void> mostrarCalculadoraTasa(
  BuildContext context,
  ControladorTasa controlador,
) => showDialog<void>(
  context: context,
  builder: (_) => DialogoCalculadoraTasa(controlador: controlador),
);

/// Dollars ⇄ bolívares at the current rate: typing in one field fills
/// the other. Nothing is saved.
class DialogoCalculadoraTasa extends StatefulWidget {
  const DialogoCalculadoraTasa({super.key, required this.controlador});

  static const _ancho = 400.0;

  final ControladorTasa controlador;

  @override
  State<DialogoCalculadoraTasa> createState() => _DialogoCalculadoraTasaState();
}

class _DialogoCalculadoraTasaState extends State<DialogoCalculadoraTasa> {
  final _dolares = TextEditingController();
  final _bolivares = TextEditingController();
  final _focoDolares = FocusNode();
  final _focoBolivares = FocusNode();

  @override
  void initState() {
    super.initState();
    // Only the field being typed in rewrites the other, so they never loop.
    _dolares.addListener(() {
      if (_focoDolares.hasFocus) {
        _convertir(_dolares, _bolivares, (tasa, v) => tasa.aBolivares(v));
      }
    });
    _bolivares.addListener(() {
      if (_focoBolivares.hasFocus) {
        _convertir(_bolivares, _dolares, (tasa, v) => tasa.aDolares(v));
      }
    });
  }

  @override
  void dispose() {
    _dolares.dispose();
    _bolivares.dispose();
    _focoDolares.dispose();
    _focoBolivares.dispose();
    super.dispose();
  }

  void _convertir(
    TextEditingController desde,
    TextEditingController hacia,
    int Function(TasaCambio tasa, int valor) conversion,
  ) {
    final tasa = widget.controlador.tasa;
    final valor = parseDecimal(desde.text, decimales: decimalesDinero);
    final texto = tasa == null || valor == null
        ? ''
        : formatDecimal(
            conversion(tasa, valor),
            decimales: decimalesDinero,
            minDecimales: decimalesDinero,
          );
    if (hacia.text != texto) hacia.text = texto;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final tasa = widget.controlador.tasa;
    final deHoy = widget.controlador.esDeHoy;
    final estilo = tema.textTheme.bodySmall?.copyWith(
      color: colores.onSurfaceVariant,
    );
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DialogoCalculadoraTasa._ancho,
        ),
        child: Padding(
          padding: EdgeInsets.all(espaciado.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: espaciado.lg,
            children: [
              const EncabezadoDialogo(
                titulo: 'Calculadora',
                icono: Icons.calculate_outlined,
              ),
              if (tasa == null)
                Text(
                  'Aún no hay tasa. Ponla con Ctrl+T para poder calcular.',
                  style: estilo?.copyWith(color: colores.error),
                )
              else
                Text(
                  '1 \$ = ${formatearBolivares(tasa.bolivaresPorDolar)} · '
                  '${deHoy ? 'tasa de hoy' : 'última tasa, del ${formatearFechaLarga(tasa.fecha)}'}',
                  style: deHoy
                      ? estilo
                      : estilo?.copyWith(color: colores.error),
                ),
              CampoCantidad(
                etiqueta: 'Dólares',
                controller: _dolares,
                focusNode: _focoDolares,
                decimales: decimalesDinero,
                sufijo: '\$',
                autofocus: true,
              ),
              CampoCantidad(
                etiqueta: 'Bolívares',
                controller: _bolivares,
                focusNode: _focoBolivares,
                decimales: decimalesDinero,
                sufijo: 'Bs',
              ),
              Text(
                'Escribe en cualquiera de los dos; Tab cambia de campo.',
                style: estilo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
