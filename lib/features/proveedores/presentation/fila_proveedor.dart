import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/suministro.dart';

class FilaProveedor extends StatelessWidget {
  const FilaProveedor({
    super.key,
    required this.proveedor,
    required this.suministros,
    required this.elegido,
    required this.onElegir,
  });

  static const _alto = 64.0;

  final Proveedor proveedor;
  final List<Suministro> suministros;
  final bool elegido;
  final VoidCallback onElegir;

  String get _contacto => [
    proveedor.telefono,
    proveedor.contacto,
  ].where((t) => t.isNotEmpty).join(' · ');

  String get _resumen {
    final marcas = marcasDe(suministros).length;
    final productos = {for (final s in suministros) s.producto.id}.length;
    return '$marcas ${marcas == 1 ? 'marca' : 'marcas'} · '
        '$productos ${productos == 1 ? 'producto' : 'productos'}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    return Semantics(
      selected: elegido,
      button: true,
      child: InkWell(
        onTap: onElegir,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: elegido ? colores.primary.withValues(alpha: 0.08) : null,
            border: Border(
              top: BorderSide(color: colores.outlineVariant),
              left: BorderSide(
                color: elegido ? colores.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _alto),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: espaciado.lg,
                vertical: espaciado.sm,
              ),
              child: Row(
                spacing: espaciado.md,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proveedor.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            fontWeight: elegido
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        if (_contacto.isNotEmpty)
                          Text(
                            _contacto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: colores.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(_resumen, style: tema.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
