import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';

class TecladoPin extends StatelessWidget {
  const TecladoPin({
    super.key,
    required this.cargando,
    required this.puedeEntrar,
    required this.onDigito,
    required this.onBorrar,
    required this.onEntrar,
    this.etiquetaEntrar = 'Entrar',
  });

  static const _filas = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  final bool cargando;
  final bool puedeEntrar;
  final ValueChanged<String> onDigito;
  final VoidCallback onBorrar;
  final VoidCallback onEntrar;
  final String etiquetaEntrar;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return Column(
      spacing: espaciado.sm,
      children: [
        for (final fila in _filas)
          Row(
            spacing: espaciado.sm,
            children: [
              for (final digito in fila)
                _Celda(
                  child: _TeclaDigito(
                    digito,
                    habilitada: !cargando,
                    onPulsar: onDigito,
                  ),
                ),
            ],
          ),
        Row(
          spacing: espaciado.sm,
          children: [
            _Celda(
              child: IconButton(
                tooltip: 'Borrar',
                icon: const Icon(Icons.backspace_outlined),
                onPressed: cargando ? null : onBorrar,
              ),
            ),
            _Celda(
              child: _TeclaDigito(
                '0',
                habilitada: !cargando,
                onPulsar: onDigito,
              ),
            ),
            _Celda(
              child: FilledButton(
                onPressed: puedeEntrar && !cargando ? onEntrar : null,
                child: cargando
                    ? SizedBox.square(
                        dimension: espaciado.lg,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(etiquetaEntrar),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda({required this.child});

  static const _altura = 60.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(height: _altura, child: child),
    );
  }
}

class _TeclaDigito extends StatelessWidget {
  const _TeclaDigito(
    this.digito, {
    required this.habilitada,
    required this.onPulsar,
  });

  final String digito;
  final bool habilitada;
  final ValueChanged<String> onPulsar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return OutlinedButton(
      onPressed: habilitada ? () => onPulsar(digito) : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: tema.colorScheme.surfaceContainerLowest,
        textStyle: tema.textTheme.titleLarge,
      ),
      child: Text(digito),
    );
  }
}
