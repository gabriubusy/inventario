import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/app/tecla_atajo.dart';
import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/presentation/opciones_marca_compra.dart';
import 'package:inventario/features/entradas/presentation/buscador_producto_entrada.dart';
import 'package:inventario/features/entradas/presentation/campo_cantidad_recibida.dart';
import 'package:inventario/features/entradas/presentation/producto_elegido.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// Adds one product line to the invoice: product, brand, amounts and cost.
/// Enter on the cost (or Ctrl+Enter anywhere) adds it and starts the next.
class EditorLineaCompra extends StatefulWidget {
  const EditorLineaCompra({
    super.key,
    required this.productos,
    required this.proveedor,
    required this.onAgregar,
    this.conOtraMarca = true,
  });

  final List<Producto> productos;

  /// False to only offer brands already in stock, as when sending back.
  final bool conOtraMarca;

  /// The invoice's supplier, whose brands are offered.
  final String proveedor;
  final ValueChanged<LineaCompra> onAgregar;

  @override
  State<EditorLineaCompra> createState() => EditorLineaCompraState();
}

class EditorLineaCompraState extends State<EditorLineaCompra> {
  final _formulario = GlobalKey<FormState>();
  final _busqueda = TextEditingController();
  final _marca = TextEditingController();
  final _piezas = TextEditingController();
  final _cantidad = TextEditingController();
  final _costo = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _focoMarca = FocusNode();
  final _focoPiezas = FocusNode();
  final _focoCantidad = FocusNode();
  Producto? _producto;
  int? _lote;

  @override
  void dispose() {
    for (final c in [_busqueda, _marca, _piezas, _cantidad, _costo]) {
      c.dispose();
    }
    for (final f in [_focoBusqueda, _focoMarca, _focoPiezas, _focoCantidad]) {
      f.dispose();
    }
    super.dispose();
  }

  List<LoteMarca> get _lotes {
    final producto = _producto;
    if (producto == null) return const [];
    final clave = normalizarParaBusqueda(widget.proveedor);
    return [
      for (final l in producto.lotes)
        if (normalizarParaBusqueda(l.proveedor) == clave) l,
    ];
  }

  void _enfocarDespues(FocusNode foco) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) foco.requestFocus();
      });

  void _enfocarCantidades() => _enfocarDespues(
    _lote == null
        ? _focoMarca
        : (_producto?.forma.cuentaPiezas ?? false)
        ? _focoPiezas
        : _focoCantidad,
  );

  void _elegirProducto(Producto producto) {
    setState(() => _producto = producto);
    _elegirLote(_lotes.isEmpty ? null : 0);
  }

  /// Also offers the brand's last cost, so a repeat purchase is just Enter.
  void _elegirLote(int? indice) {
    setState(() => _lote = indice);
    final costo = indice == null ? null : _lotes[indice].costo;
    _costo.text = costo == null
        ? ''
        : formatDecimal(costo, decimales: decimalesDinero, minDecimales: 2);
    _enfocarCantidades();
  }

  /// Alt+1… from the window; the last number is "Otra marca".
  void elegirMarca(int indice) {
    final limite = widget.conOtraMarca ? _lotes.length : _lotes.length - 1;
    if (_producto == null || indice > limite) return;
    _elegirLote(indice == _lotes.length ? null : indice);
  }

  void _cambiarProducto() {
    setState(() {
      _producto = null;
      _lote = null;
    });
    for (final c in [_busqueda, _marca, _piezas, _cantidad, _costo]) {
      c.clear();
    }
    _enfocarDespues(_focoBusqueda);
  }

  /// Adds the line if it is complete; true when added.
  bool agregar() {
    final producto = _producto;
    if (producto == null || !(_formulario.currentState?.validate() ?? false)) {
      return false;
    }
    final lote = _lote;
    final forma = producto.forma;
    widget.onAgregar(
      LineaCompra(
        productoId: producto.id,
        producto: producto.nombre,
        forma: forma,
        marca: lote == null ? _marca.text.trim() : _lotes[lote].marca,
        piezas: forma.cuentaPiezas ? CampoCantidadRecibida.leer(_piezas, 0) : 0,
        cantidad: CampoCantidadRecibida.leer(_cantidad, forma.unidad.decimales),
        costo: CampoCantidadRecibida.leer(_costo, decimalesDinero),
      ),
    );
    _cambiarProducto();
    return true;
  }

  void _enterEnCosto() {
    if (HardwareKeyboard.instance.isControlPressed) return;
    agregar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final espaciado = context.espaciado;
    final producto = _producto;
    return Form(
      key: _formulario,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: espaciado.md,
        children: [
          if (producto == null)
            BuscadorProductoEntrada(
              productos: widget.productos,
              controller: _busqueda,
              focusNode: _focoBusqueda,
              onElegir: _elegirProducto,
              validator: (_) => 'Elige un producto de la lista',
            )
          else ...[
            ProductoElegido(producto: producto, onCambiar: _cambiarProducto),
            ExcludeFocus(
              child: OpcionesMarcaCompra(
                producto: producto,
                lotes: _lotes,
                elegido: _lote,
                onElegir: _elegirLote,
                conOtraMarca: widget.conOtraMarca,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: espaciado.md,
              children: [
                if (_lote == null)
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _marca,
                      focusNode: _focoMarca,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Marca'),
                      validator: (t) =>
                          (t == null || t.trim().isEmpty) ? 'Falta' : null,
                    ),
                  ),
                if (producto.forma.cuentaPiezas)
                  Expanded(
                    child: CampoCantidadRecibida(
                      etiqueta: 'Piezas',
                      controller: _piezas,
                      focusNode: _focoPiezas,
                      decimales: 0,
                    ),
                  ),
                Expanded(
                  child: CampoCantidadRecibida(
                    etiqueta: producto.forma.cuentaPiezas ? 'Peso' : 'Cantidad',
                    controller: _cantidad,
                    focusNode: _focoCantidad,
                    decimales: producto.forma.unidad.decimales,
                    sufijo: producto.forma.unidad.simbolo,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _costo,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                    ],
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Costo /${producto.forma.unidad.simbolo}',
                      prefixText: r'$ ',
                    ),
                    validator: (t) {
                      final valor = parseDecimal(
                        t ?? '',
                        decimales: decimalesDinero,
                      );
                      if (valor == null) return 'Falta';
                      return valor <= 0 ? 'Mayor que 0' : null;
                    },
                    onFieldSubmitted: (_) => _enterEnCosto(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: espaciado.xs),
                  child: OutlinedButton(
                    onPressed: agregar,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: Row(
                      spacing: espaciado.sm,
                      children: [
                        const Text('Añadir'),
                        TeclaAtajo('Enter', color: colores.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
