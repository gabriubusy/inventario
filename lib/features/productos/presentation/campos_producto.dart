import 'package:flutter/material.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/presentation/con_etiqueta.dart';
import 'package:inventario/features/productos/presentation/forma_bloqueada.dart';
import 'package:inventario/features/productos/presentation/foto_editable.dart';
import 'package:inventario/features/productos/presentation/seccion_foto.dart';
import 'package:inventario/features/productos/presentation/selector_categoria.dart';
import 'package:inventario/features/productos/presentation/selector_forma_conteo.dart';

/// Photo, name, category and way of counting: the top of the product form.
class CamposProducto extends StatelessWidget {
  const CamposProducto({
    super.key,
    required this.foto,
    required this.fotos,
    required this.campoNombre,
    required this.nombre,
    required this.focoNombre,
    required this.autofocus,
    required this.validarNombre,
    required this.onNombreCambiado,
    required this.categoria,
    required this.onCategoria,
    required this.forma,
    required this.formaEditable,
    required this.onForma,
  });

  final FotoEditable foto;
  final GestorFotos fotos;
  final GlobalKey<FormFieldState<String>> campoNombre;
  final TextEditingController nombre;
  final FocusNode focoNombre;
  final bool autofocus;
  final FormFieldValidator<String> validarNombre;
  final ValueChanged<String> onNombreCambiado;
  final Categoria categoria;
  final ValueChanged<Categoria> onCategoria;
  final FormaConteo forma;
  final bool formaEditable;
  final ValueChanged<FormaConteo> onForma;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.espaciado.lg,
      children: [
        SeccionFoto(foto: foto, fotos: fotos, nombre: nombre.text),
        TextFormField(
          key: campoNombre,
          controller: nombre,
          focusNode: focoNombre,
          autofocus: autofocus,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Nombre'),
          validator: validarNombre,
          onChanged: onNombreCambiado,
        ),
        // Excluded from Tab/Enter: they have their own Alt shortcuts.
        ConEtiqueta(
          etiqueta: 'Categoría',
          child: ExcludeFocus(
            child: SelectorCategoria(elegida: categoria, onElegir: onCategoria),
          ),
        ),
        if (formaEditable)
          ConEtiqueta(
            etiqueta: 'Cómo se cuenta',
            child: ExcludeFocus(
              child: SelectorFormaConteo(elegida: forma, onElegir: onForma),
            ),
          )
        else
          FormaBloqueada(forma: forma),
      ],
    );
  }
}
