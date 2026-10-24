import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';

/// Search box; Esc clears it.
class BuscadorProductos extends StatefulWidget {
  const BuscadorProductos({
    super.key,
    required this.controlador,
    required this.focusNode,
  });

  final ControladorExistencias controlador;
  final FocusNode focusNode;

  @override
  State<BuscadorProductos> createState() => _BuscadorProductosState();
}

class _BuscadorProductosState extends State<BuscadorProductos> {
  late final _texto = TextEditingController(text: widget.controlador.busqueda);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _limpiar() {
    _texto.clear();
    widget.controlador.buscar('');
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _limpiar},
      child: ValueListenableBuilder(
        valueListenable: _texto,
        builder: (context, valor, _) => TextField(
          controller: _texto,
          focusNode: widget.focusNode,
          onChanged: widget.controlador.buscar,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar producto (Ctrl+K)',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: valor.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    icon: const Icon(Icons.close),
                    onPressed: _limpiar,
                  ),
          ),
        ),
      ),
    );
  }
}
