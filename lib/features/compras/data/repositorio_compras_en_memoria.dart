import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/compras/domain/repositorio_compras.dart';

/// For tests; lost when the app closes.
class RepositorioComprasEnMemoria implements RepositorioCompras {
  RepositorioComprasEnMemoria({
    List<Compra> compras = const [],
    List<Pago> pagos = const [],
  }) : _compras = [...compras],
       _pagos = [...pagos];

  final List<Compra> _compras;
  final List<Pago> _pagos;
  var _ultimoId = 0;

  @override
  Future<List<Compra>> obtenerCompras() async => List.unmodifiable(_compras);

  @override
  Future<List<Pago>> obtenerPagos() async => List.unmodifiable(_pagos);

  @override
  Future<Compra> crearCompra(Compra compra) async {
    final guardada = compra.conId('c${++_ultimoId}');
    _compras.add(guardada);
    return guardada;
  }

  @override
  Future<void> borrarCompra(String id) async {
    _compras.removeWhere((c) => c.id == id);
    _pagos.removeWhere((p) => p.compraId == id);
  }

  @override
  Future<Pago> crearPago(Pago pago) async {
    final guardado = pago.conId('p${++_ultimoId}');
    _pagos.add(guardado);
    return guardado;
  }

  @override
  Future<void> borrarPago(String id) async =>
      _pagos.removeWhere((p) => p.id == id);

  @override
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    final clave = normalizarParaBusqueda(anterior);
    for (final (i, compra) in _compras.indexed) {
      if (normalizarParaBusqueda(compra.proveedor) == clave) {
        _compras[i] = compra.conProveedor(nuevo);
      }
    }
  }
}
