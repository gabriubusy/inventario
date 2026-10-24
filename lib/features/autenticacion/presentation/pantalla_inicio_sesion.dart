import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/presentation/encabezado_inicio_sesion.dart';
import 'package:inventario/features/autenticacion/presentation/entrada_pin.dart';

class PantallaInicioSesion extends StatelessWidget {
  const PantallaInicioSesion({super.key, required this.controlador});

  static const _anchoMaximo = 360.0;

  final ControladorSesion controlador;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(espaciado.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _anchoMaximo),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: espaciado.xl,
                  vertical: espaciado.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const EncabezadoInicioSesion(),
                    SizedBox(height: espaciado.xl),
                    EntradaPin(controlador: controlador),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
