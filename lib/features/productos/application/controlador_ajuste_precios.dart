import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/ajustar_precios.dart';
import 'package:inventario/features/productos/domain/ambito_ajuste.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// One product before and after a bulk price change.
typedef CambioAjuste = ({Producto antes, Producto despues});

/// Raises or lowers one price list over many products at once, and can put
/// them back while nothing else changed them.
class ControladorAjustePrecios {
  ControladorAjustePrecios(
    this._existencias, {
    this._transacciones = const SinTransaccion(),
  });

  final ControladorExistencias _existencias;
  final Transacciones _transacciones;
  List<CambioAjuste>? _ultimo;

  /// The products [ambito] covers whose [lista] prices would move.
  List<CambioAjuste> previsto(
    AmbitoAjuste ambito,
    ListaPrecio lista,
    int porcentaje,
  ) => [
    for (final producto in _existencias.productos)
      if (lista == ListaPrecio.detal
          ? ambito.incluye(producto)
          : ambito.incluyeRegla(producto))
        if (ajustarPrecios(
              producto,
              lista,
              porcentaje,
              lote: ambito.incluyeLote,
              presentaciones: ambito.incluyePresentaciones,
            )
            case final despues when despues != producto)
          (antes: producto, despues: despues),
  ];

  /// How many products changed.
  Future<int> aplicar(
    AmbitoAjuste ambito,
    ListaPrecio lista,
    int porcentaje,
  ) async {
    final cambios = previsto(ambito, lista, porcentaje);
    if (cambios.isEmpty) return 0;
    final guardados = await _transacciones.enUna(() async {
      final guardados = <CambioAjuste>[];
      for (final cambio in cambios) {
        await _existencias.actualizarProducto(
          cambio.antes.id,
          DatosProducto.desde(cambio.despues),
        );
        if (_buscar(cambio.antes.id) case final actual?) {
          guardados.add((antes: cambio.antes, despues: actual));
        }
      }
      return guardados;
    });
    _ultimo = guardados;
    return guardados.length;
  }

  /// False when one of them changed since, so the whole change stays.
  Future<bool> deshacer() async {
    final ultimo = _ultimo;
    _ultimo = null;
    if (ultimo == null) return false;
    if (ultimo.any((c) => _buscar(c.antes.id) != c.despues)) return false;
    await _transacciones.enUna(() async {
      for (final cambio in ultimo) {
        await _existencias.actualizarProducto(
          cambio.antes.id,
          DatosProducto.desde(cambio.antes),
        );
      }
    });
    return true;
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
