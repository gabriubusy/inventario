import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/presentation/fila_proveedor.dart';

class ListaProveedores extends StatelessWidget {
  const ListaProveedores({
    super.key,
    required this.controlador,
    required this.focoBusqueda,
  });

  final ControladorProveedores controlador;
  final FocusNode focoBusqueda;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    final proveedores = controlador.visibles;
    final elegido = controlador.elegido;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(espaciado.lg),
            child: _Buscador(controlador: controlador, focusNode: focoBusqueda),
          ),
          Expanded(
            child: proveedores.isEmpty
                ? Center(
                    child: Text(
                      'No hay proveedores que coincidan',
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: proveedores.length,
                    itemBuilder: (context, i) {
                      final proveedor = proveedores[i];
                      return FilaProveedor(
                        proveedor: proveedor,
                        suministros: controlador.suministros(proveedor),
                        elegido: proveedor == elegido,
                        onElegir: () => controlador.elegir(proveedor.id),
                      );
                    },
                  ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: tema.colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(espaciado.md),
              child: Text(
                '↑ ↓ moverse · Ctrl+E editar el elegido',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Buscador extends StatefulWidget {
  const _Buscador({required this.controlador, required this.focusNode});

  final ControladorProveedores controlador;
  final FocusNode focusNode;

  @override
  State<_Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends State<_Buscador> {
  late final _texto = TextEditingController(text: widget.controlador.busqueda);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _texto,
      focusNode: widget.focusNode,
      onChanged: widget.controlador.buscar,
      decoration: const InputDecoration(
        hintText: 'Buscar por nombre o marca (Ctrl+K)',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
