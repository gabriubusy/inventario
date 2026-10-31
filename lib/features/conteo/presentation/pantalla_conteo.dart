import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventario/app/atajos_de_teclado.dart';
import 'package:inventario/app/espaciado.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/conteo/domain/aplicar_conteo.dart';
import 'package:inventario/features/conteo/domain/conteo_lote.dart';
import 'package:inventario/features/conteo/presentation/barra_conteo.dart';
import 'package:inventario/features/conteo/presentation/fila_conteo.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

typedef _Fila = ({Producto producto, LoteMarca lote, String clave});

/// F9: type what is on the shelves for many products, then save all the
/// differences at once with Ctrl+S.
class PantallaConteo extends StatefulWidget {
  const PantallaConteo({
    super.key,
    required this.conteo,
    required this.existencias,
  });

  static const _anchoMaximo = 1240.0;

  final ControladorConteo conteo;
  final ControladorExistencias existencias;

  @override
  State<PantallaConteo> createState() => _PantallaConteoState();
}

class _PantallaConteoState extends State<PantallaConteo> {
  final _busqueda = TextEditingController();
  final _focoBusqueda = FocusNode();
  final _campos = <String, CamposConteo>{};
  var _guardando = false;

  @override
  void initState() {
    super.initState();
    _busqueda.addListener(_refrescar);
    for (final MapEntry(key: clave, value: texto)
        in widget.conteo.borrador.entries) {
      final campos = _camposDe(clave);
      campos.piezas.text = texto.piezas;
      campos.cantidad.text = texto.cantidad;
    }
  }

  @override
  void dispose() {
    // Kept for the next visit, like the open ticket in the sale window.
    widget.conteo.borrador = {
      for (final MapEntry(key: clave, value: campos) in _campos.entries)
        if (campos.piezas.text.trim().isNotEmpty ||
            campos.cantidad.text.trim().isNotEmpty)
          clave: (piezas: campos.piezas.text, cantidad: campos.cantidad.text),
    };
    _busqueda.dispose();
    _focoBusqueda.dispose();
    for (final campos in _campos.values) {
      campos.piezas.dispose();
      campos.cantidad.dispose();
    }
    super.dispose();
  }

  void _refrescar() => setState(() {});

  static String _clave(Producto p, LoteMarca l) =>
      '${p.id}|${normalizarParaBusqueda(l.marca)}|'
      '${normalizarParaBusqueda(l.proveedor)}';

  CamposConteo _camposDe(String clave) => _campos.putIfAbsent(clave, () {
    final campos = (
      piezas: TextEditingController(),
      cantidad: TextEditingController(),
    );
    campos.piezas.addListener(_refrescar);
    campos.cantidad.addListener(_refrescar);
    return campos;
  });

  /// Every brand of every product, searched or not.
  List<_Fila> get _todas => [
    for (final producto in widget.existencias.productos)
      for (final lote in producto.lotes)
        (producto: producto, lote: lote, clave: _clave(producto, lote)),
  ];

  /// The rows the search leaves on screen.
  List<_Fila> get _filas {
    final buscado = normalizarParaBusqueda(_busqueda.text);
    if (buscado.isEmpty) return _todas;
    return [
      for (final fila in _todas)
        if (normalizarParaBusqueda(fila.producto.nombre).contains(buscado))
          fila,
    ];
  }

  /// What was typed for a row; null while the weight is empty or invalid.
  ConteoLote? _conteo(_Fila fila) {
    final campos = _campos[fila.clave];
    if (campos == null) return null;
    final forma = fila.producto.forma;
    final cantidad = FilaConteo.leer(
      campos.cantidad.text,
      forma.unidad.decimales,
      unidad: forma.unidad,
    );
    if (cantidad == null) return null;
    return ConteoLote(
      productoId: fila.producto.id,
      marca: fila.lote.marca,
      proveedor: fila.lote.proveedor,
      piezas: forma.cuentaPiezas
          ? FilaConteo.leer(campos.piezas.text, 0)
          : null,
      cantidad: cantidad,
    );
  }

  // All rows, not only the searched ones: a count typed before searching
  // for another product must not be lost.
  List<ConteoLote> get _conDiferencia => [
    for (final fila in _todas)
      if (_conteo(fila) case final conteo?)
        if (hayDiferencia(diferenciaConteo(fila.lote, conteo))) conteo,
  ];

  void _volver() {
    if (_busqueda.text.isNotEmpty) {
      _busqueda.clear();
      return;
    }
    unawaited(Navigator.of(context).maybePop());
  }

  Future<void> _guardar() async {
    final conteos = _conDiferencia;
    if (_guardando || conteos.isEmpty) return;
    setState(() => _guardando = true);
    final mensajero = ScaffoldMessenger.of(context);
    final guardados = await widget.conteo.guardar(conteos);
    if (!mounted) return;
    for (final campos in _campos.values) {
      campos.piezas.clear();
      campos.cantidad.clear();
    }
    setState(() => _guardando = false);
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            guardados == 1
                ? 'Conteo guardado: 1 ajuste'
                : 'Conteo guardado: $guardados ajustes',
          ),
          persist: false,
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => unawaited(_deshacer(mensajero)),
          ),
        ),
      );
  }

  Future<void> _deshacer(ScaffoldMessengerState mensajero) async {
    final fallidos = await widget.conteo.deshacer();
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            fallidos == 0
                ? 'Conteo deshecho'
                : '$fallidos no se pudieron deshacer: cambiaron después',
          ),
        ),
      );
  }

  Map<ShortcutActivator, VoidCallback> get _atajos => {
    const SingleActivator(LogicalKeyboardKey.escape): _volver,
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        _focoBusqueda.requestFocus,
    const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
        unawaited(_guardar()),
  };

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final espaciado = context.espaciado;
    return AtajosDeTeclado(
      atajos: _atajos,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: widget.existencias,
          builder: (context, _) {
            final filas = _filas;
            final cambios = _conDiferencia.length;
            return Column(
              children: [
                BarraConteo(
                  busqueda: _busqueda,
                  focoBusqueda: _focoBusqueda,
                  cambios: cambios,
                  guardando: _guardando,
                  onVolver: _volver,
                  onGuardar: () => unawaited(_guardar()),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: PantallaConteo._anchoMaximo,
                      ),
                      child: ListView(
                        padding: EdgeInsets.all(espaciado.xl),
                        children: [
                          Text(
                            'Escribe lo que hay en la tienda; Enter pasa al '
                            'siguiente. Lo que dejes vacío no cambia. Si '
                            'sales sin guardar, lo escrito te espera aquí.',
                            style: tema.textTheme.bodyMedium?.copyWith(
                              color: tema.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: espaciado.md),
                          Card(
                            child: Column(
                              children: [
                                for (final fila in filas)
                                  FilaConteo(
                                    key: ValueKey(fila.clave),
                                    producto: fila.producto,
                                    lote: fila.lote,
                                    campos: _camposDe(fila.clave),
                                    diferencia: switch (_conteo(fila)) {
                                      final conteo? => diferenciaConteo(
                                        fila.lote,
                                        conteo,
                                      ),
                                      null => null,
                                    },
                                  ),
                                if (filas.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(espaciado.xl),
                                    child: const Text(
                                      'No hay productos que coincidan',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
