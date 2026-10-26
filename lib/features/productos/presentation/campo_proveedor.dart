import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/texto.dart';

/// Supplier field that suggests saved suppliers, so lots stay linked to the
/// same name. Free text is still allowed for a supplier not saved yet.
class CampoProveedor extends StatelessWidget {
  const CampoProveedor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sugerencias,
  });

  static const _altoLista = 220.0;
  static const _anchoLista = 300.0;

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> sugerencias;

  Iterable<String> _opciones(TextEditingValue valor) {
    final buscado = normalizarParaBusqueda(valor.text);
    if (buscado.isEmpty) return const [];
    return sugerencias.where((nombre) {
      final clave = normalizarParaBusqueda(nombre);
      return clave.contains(buscado) && clave != buscado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: _opciones,
      fieldViewBuilder: (context, controller, focusNode, alEnviar) =>
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Proveedor'),
            // Enter takes the highlighted suggestion before moving on.
            onFieldSubmitted: (_) => alEnviar(),
          ),
      optionsViewBuilder: (context, alElegir, opciones) =>
          _ListaSugerencias(opciones: opciones.toList(), alElegir: alElegir),
    );
  }
}

class _ListaSugerencias extends StatelessWidget {
  const _ListaSugerencias({required this.opciones, required this.alElegir});

  final List<String> opciones;
  final AutocompleteOnSelected<String> alElegir;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    final resaltada = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        color: colores.surface,
        borderRadius: BorderRadius.circular(espaciado.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: CampoProveedor._altoLista,
            maxWidth: CampoProveedor._anchoLista,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: espaciado.xs),
            itemCount: opciones.length,
            itemBuilder: (context, i) => ListTile(
              dense: true,
              selected: i == resaltada,
              selectedTileColor: colores.primary.withValues(alpha: 0.08),
              title: Text(opciones[i]),
              onTap: () => alElegir(opciones[i]),
            ),
          ),
        ),
      ),
    );
  }
}
