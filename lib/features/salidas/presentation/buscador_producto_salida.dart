import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/productos/domain/buscar_por_codigo.dart';
import 'package:inventario/features/productos/domain/presentacion.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';

/// Product search by name, or by a pack's code as a barcode scanner types
/// it followed by Enter; the scanned pack then comes chosen.
class BuscadorProductoSalida extends StatelessWidget {
  const BuscadorProductoSalida({
    super.key,
    required this.productos,
    required this.controller,
    required this.focusNode,
    required this.onElegir,
  });

  static const _maximo = 8;
  static const _altoLista = 320.0;
  static const _anchoLista = 460.0;

  final List<Producto> productos;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(Producto producto, Presentacion? presentacion) onElegir;

  Iterable<Producto> _opciones(TextEditingValue valor) {
    final buscado = normalizarParaBusqueda(valor.text);
    if (buscado.isEmpty) return const [];
    final porCodigo = buscarPorCodigo(productos, valor.text);
    return [
      ?porCodigo?.producto,
      ...productos.where(
        (p) =>
            p != porCodigo?.producto &&
            normalizarParaBusqueda(p.nombre).contains(buscado),
      ),
    ].take(_maximo);
  }

  /// An exact code wins over the highlighted suggestion.
  void _enviar(VoidCallback alEnviar) {
    final porCodigo = buscarPorCodigo(productos, controller.text);
    if (porCodigo != null) {
      onElegir(porCodigo.producto, porCodigo.presentacion);
    } else {
      alEnviar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Producto>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: _opciones,
      displayStringForOption: (producto) => producto.nombre,
      onSelected: (producto) => onElegir(producto, null),
      fieldViewBuilder: (context, controller, focusNode, alEnviar) =>
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Producto',
              hintText: 'Escribe parte del nombre o escanea el código',
              prefixIcon: Icon(Icons.search),
            ),
            validator: (_) => 'Elige un producto de la lista',
            onFieldSubmitted: (_) => _enviar(alEnviar),
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
          trailing: Text(textoStock(producto)),
          onTap: () => alElegir(producto),
        );
      },
    );
  }
}
