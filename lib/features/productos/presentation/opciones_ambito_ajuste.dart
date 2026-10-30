import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/domain/ambito_ajuste.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';

/// Which list moves and over which products.
class OpcionesAmbitoAjuste extends StatelessWidget {
  const OpcionesAmbitoAjuste({
    super.key,
    required this.lista,
    required this.ambito,
    required this.proveedores,
    required this.onLista,
    required this.onAmbito,
  });

  final ListaPrecio lista;
  final AmbitoAjuste ambito;
  final List<String> proveedores;
  final ValueChanged<ListaPrecio> onLista;
  final ValueChanged<AmbitoAjuste> onAmbito;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    Widget chips(List<Widget> hijos) => _Chips(hijos);
    ChoiceChip chip(String texto, {required bool elegido, VoidCallback? on}) =>
        ChoiceChip(
          label: Text(texto),
          selected: elegido,
          showCheckmark: false,
          onSelected: on == null ? null : (_) => on(),
        );
    final ambito = this.ambito;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: espaciado.lg,
      children: [
        ConEtiqueta(
          etiqueta: 'Lista',
          ayuda: lineasAyuda(
            [for (final l in ListaPrecio.values) l.etiqueta],
            [for (var i = 1; i <= ListaPrecio.values.length; i++) 'Alt+$i'],
          ).join('\n'),
          child: chips([
            for (final l in ListaPrecio.values)
              chip(l.etiqueta, elegido: l == lista, on: () => onLista(l)),
          ]),
        ),
        ConEtiqueta(
          etiqueta: 'A qué productos',
          ayuda:
              'Todos · Alt+A\n'
              'Una categoría · Alt+S\n'
              'Un proveedor · Alt+D\n'
              'Repetir la tecla pasa a la siguiente',
          child: chips([
            chip(
              'Todos',
              elegido: ambito is TodosLosProductos,
              on: () => onAmbito(const TodosLosProductos()),
            ),
            chip(
              'Una categoría',
              elegido: ambito is DeCategoria,
              on: () => onAmbito(DeCategoria(Categoria.values.first)),
            ),
            chip(
              'Un proveedor',
              elegido: ambito is DeProveedor,
              on: proveedores.isEmpty
                  ? null
                  : () => onAmbito(DeProveedor(proveedores.first)),
            ),
          ]),
        ),
        switch (ambito) {
          TodosLosProductos() => const SizedBox.shrink(),
          DeCategoria(:final categoria) => chips([
            for (final c in Categoria.values)
              chip(
                c.etiqueta,
                elegido: c == categoria,
                on: () => onAmbito(DeCategoria(c)),
              ),
          ]),
          DeProveedor(:final proveedor) => chips([
            for (final p in proveedores)
              chip(
                p,
                elegido: p == proveedor,
                on: () => onAmbito(DeProveedor(p)),
              ),
          ]),
        },
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips(this.hijos);

  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    final espaciado = context.espaciado;
    return ExcludeFocus(
      child: Wrap(
        spacing: espaciado.sm,
        runSpacing: espaciado.sm,
        children: hijos,
      ),
    );
  }
}
