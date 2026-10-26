import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Product search with suggestions; Enter takes the highlighted one.
class BuscadorProductoEntrada extends StatelessWidget {
  const BuscadorProductoEntrada({
    super.key,
    required this.productos,
    required this.controller,
    required this.focusNode,
    required this.onElegir,
    required this.validator,
  });

  static const _maximo = 8;
  static const _altoLista = 320.0;
  static const _anchoLista = 460.0;

  final List<Producto> productos;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<Producto> onElegir;
  final FormFieldValidator<String> validator;

  Iterable<Producto> _opciones(TextEditingValue valor) {
    final buscado = normalizarParaBusqueda(valor.text);
    if (buscado.isEmpty) return const [];
    return productos
        .where((p) => normalizarParaBusqueda(p.nombre).contains(buscado))
        .take(_maximo);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Producto>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: _opciones,
      displayStringForOption: (producto) => producto.nombre,
      onSelected: onElegir,
      fieldViewBuilder: (context, controller, focusNode, alEnviar) =>
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Producto',
              hintText: 'Escribe parte del nombre',
              prefixIcon: Icon(Icons.search),
            ),
            validator: validator,
            onFieldSubmitted: (_) => alEnviar(),
          ),
      optionsViewBuilder: (context, alElegir, opciones) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(context.espaciado.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: _altoLista,
              maxWidth: _anchoLista,
            ),
            child: _Opciones(opciones: opciones.toList(), alElegir: alElegir),
          ),
        ),
      ),
    );
  }
}

class _Opciones extends StatelessWidget {
  const _Opciones({required this.opciones, required this.alElegir});

  final List<Producto> opciones;
  final AutocompleteOnSelected<Producto> alElegir;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final resaltada = AutocompleteHighlightedOption.of(context);
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: context.espaciado.xs),
      itemCount: opciones.length,
      itemBuilder: (context, i) {
        final producto = opciones[i];
        return ListTile(
          dense: true,
          selected: i == resaltada,
          selectedTileColor: colores.primary.withValues(alpha: 0.08),
          title: Text(producto.nombre),
          trailing: Text(textoPrincipal(producto)),
          onTap: () => alElegir(producto),
        );
      },
    );
  }
}
