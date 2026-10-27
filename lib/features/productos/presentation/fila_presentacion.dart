import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/campo_cantidad.dart';
import 'package:inventario/features/productos/presentation/presentacion_editable.dart';

/// ★ · Nombre · Contiene · Código · Precio · ✕
class FilaPresentacion extends StatelessWidget {
  const FilaPresentacion({
    super.key,
    required this.fila,
    required this.forma,
    required this.predeterminada,
    required this.codigoRepetido,
    required this.codigoOcupado,
    required this.onMarcar,
    required this.onQuitar,
  });

  final PresentacionEditable fila;
  final FormaConteo forma;
  final bool predeterminada;

  /// Asked at validation time: an earlier row has the same code.
  final bool Function() codigoRepetido;

  /// Asked at validation time: another product already uses the code.
  final bool Function(String codigo) codigoOcupado;
  final VoidCallback onMarcar;
  final VoidCallback onQuitar;

  bool _enUso() => !fila.vacio;

  String? _validarNombre(String? texto) {
    if (fila.vacio) return null;
    if (texto == null || texto.trim().isEmpty) return 'Falta';
    return null;
  }

  String? _validarCodigo(String? texto) {
    final codigo = texto?.trim() ?? '';
    if (codigo.isEmpty) return null;
    if (codigoRepetido()) return 'Ya está arriba';
    if (codigoOcupado(codigo)) return 'Lo usa otro producto';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final espaciado = context.espaciado;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: espaciado.sm,
      children: [
        ExcludeFocus(
          child: IconButton(
            tooltip: predeterminada
                ? 'Sale primero al vender'
                : 'Que salga primero al vender',
            onPressed: onMarcar,
            icon: Icon(
              predeterminada ? Icons.star : Icons.star_border,
              color: predeterminada ? colores.primary : colores.outline,
            ),
          ),
        ),
        Expanded(
          flex: 12,
          child: TextFormField(
            controller: fila.nombre,
            focusNode: fila.focoNombre,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: _validarNombre,
          ),
        ),
        Expanded(
          flex: 9,
          child: CampoCantidad(
            etiqueta: 'Contiene',
            controller: fila.contiene,
            decimales: forma.unidad.decimales,
            sufijo: forma.unidad.simbolo,
            obligatorio: _enUso,
          ),
        ),
        Expanded(
          flex: 14,
          child: TextFormField(
            controller: fila.codigo,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Código'),
            validator: _validarCodigo,
          ),
        ),
        Expanded(
          flex: 9,
          child: CampoCantidad(
            etiqueta: 'Precio',
            controller: fila.precio,
            decimales: decimalesDinero,
            sufijo: r'$',
            obligatorio: _enUso,
          ),
        ),
        ExcludeFocus(
          child: IconButton(
            tooltip: 'Quitar presentación',
            icon: const Icon(Icons.close),
            onPressed: onQuitar,
          ),
        ),
      ],
    );
  }
}
