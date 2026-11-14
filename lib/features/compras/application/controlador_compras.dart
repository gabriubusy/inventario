import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/estado_pedido.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/compras/domain/recepcion.dart';
import 'package:inventario/features/compras/domain/recibir_linea.dart';
import 'package:inventario/features/compras/domain/repositorio_compras.dart';
import 'package:inventario/features/compras/domain/resultados_compra.dart';
import 'package:inventario/features/compras/domain/resumen_cuentas.dart';
import 'package:inventario/features/compras/domain/resumen_pedidos.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';

/// An invoice being typed in F2 and not registered yet.
typedef BorradorCompra = ({
  String proveedor,
  String factura,
  List<LineaCompra> lineas,
  bool credito,
  String dias,
  MedioPago medio,
});

typedef _CambioRecepcion = ({
  Compra antes,
  Compra despues,
  List<({Producto antes, Producto despues})> productos,
  List<Movimiento> anotados,
});

/// Supplier orders (F2), what arrived of each one (Ctrl+P) and what is
/// still owed (F10). Placing an order does not touch the stock: the goods
/// come in when their arrival is confirmed, in one transaction.
class ControladorCompras extends ChangeNotifier {
  ControladorCompras(
    this._repositorio,
    this._existencias, {
    this._movimientos,
    this._transacciones = const SinTransaccion(),
    this._tasaDeHoy,
    this._ahora = DateTime.now,
  });

  final RepositorioCompras _repositorio;
  final ControladorExistencias _existencias;
  final ControladorMovimientos? _movimientos;
  final Transacciones _transacciones;

  /// Bs per dollar today (hundredths), null while missing.
  final int? Function()? _tasaDeHoy;
  final DateTime Function() _ahora;
  List<Compra> _compras = const [];
  List<Pago> _pagos = const [];
  Map<String, int> _devuelto = const {};
  Compra? _ultimaCompra;
  _CambioRecepcion? _ultimaRecepcion;
  Pago? _ultimoPago;

  DateTime get hoy => _ahora();
  int? get tasaDeHoy => _tasaDeHoy?.call();
  bool get puedeDeshacerCompra => _ultimaCompra != null;
  bool get puedeDeshacerRecepcion => _ultimaRecepcion != null;

  /// Kept when F2 closes with lines still unregistered (Esc), so a long
  /// invoice is not typed twice. Null once it is registered.
  BorradorCompra? borrador;

  /// Newest first.
  List<Compra> get compras => _compras;

  /// Orders with goods still on the way, the oldest first.
  List<Compra> get pendientes => [
    for (final c in _compras.reversed)
      if (c.estado.esperando) c,
  ];

  ResumenPedidos get resumenPedidos => ResumenPedidos.de(_compras, hoy);

  /// Every payment made to suppliers.
  List<Pago> get pagos => _pagos;

  /// Every invoice on credit with its payments, the soonest due first.
  List<CuentaPorPagar> get cuentas => [
    for (final compra in _compras)
      if (compra.aCredito)
        CuentaPorPagar(
          compra: compra,
          pagos: [
            for (final p in _pagos)
              if (p.compraId == compra.id) p,
          ],
          devuelto: _devuelto[compra.id] ?? 0,
        ),
  ]..sort((a, b) => a.compra.vence!.compareTo(b.compra.vence!));

  /// What returns to suppliers took off each invoice; set by whoever keeps
  /// those returns.
  void fijarDevuelto(Map<String, int> devuelto) {
    _devuelto = devuelto;
    notifyListeners();
  }

  ResumenCuentas get resumen => ResumenCuentas.de(cuentas, hoy);

  /// What is owed to one supplier, in dollar hundredths.
  int deudaDe(String proveedor) {
    final clave = normalizarParaBusqueda(proveedor);
    return cuentas
        .where((c) => normalizarParaBusqueda(c.compra.proveedor) == clave)
        .fold(0, (total, c) => total + (c.debe > 0 ? c.debe : 0));
  }

  CuentaPorPagar? cuentaDe(String compraId) {
    for (final cuenta in cuentas) {
      if (cuenta.compra.id == compraId) return cuenta;
    }
    return null;
  }

  Compra? compraDe(String id) {
    for (final compra in _compras) {
      if (compra.id == id) return compra;
    }
    return null;
  }

  Future<void> cargar() async {
    _compras = _ordenar(await _repositorio.obtenerCompras());
    _pagos = await _repositorio.obtenerPagos();
    notifyListeners();
  }

  /// Stores the order, waiting until what arrived is confirmed. The stock
  /// does not move here: the supplier may bring something else.
  Future<ResultadoCompra> registrar(Compra compra) async {
    for (final linea in compra.lineas) {
      if (_buscar(linea.productoId) == null) {
        return CompraSinProducto(linea.producto);
      }
    }
    if (compra.medio?.moneda == Moneda.bolivares && tasaDeHoy == null) {
      return const CompraSinTasa();
    }
    final guardada = await _repositorio.crearCompra(
      Compra(
        fecha: _ahora(),
        proveedor: compra.proveedor,
        factura: compra.factura,
        lineas: compra.lineas,
        vence: compra.vence,
        medio: compra.medio,
        tasa: tasaDeHoy,
      ),
    );
    _ultimaCompra = guardada;
    _compras = _ordenar([..._compras, guardada]);
    notifyListeners();
    return CompraRegistrada(guardada);
  }

  /// Takes the last order back. Refused (false) once something of it
  /// arrived, because that is stock already.
  Future<bool> deshacerCompra() async {
    final ultima = _ultimaCompra;
    if (ultima == null) return false;
    _ultimaCompra = null;
    final actual = compraDe(ultima.id);
    if (actual == null || actual.estado != EstadoPedido.pendiente) {
      notifyListeners();
      return false;
    }
    await _repositorio.borrarCompra(ultima.id);
    _compras = [
      for (final c in _compras)
        if (c.id != ultima.id) c,
    ];
    _pagos = [
      for (final p in _pagos)
        if (p.compraId != ultima.id) p,
    ];
    notifyListeners();
    return true;
  }

  /// Puts what really arrived into the stock, notes an entry per line in
  /// the kardex and keeps it on the order, all or nothing.
  Future<ResultadoRecepcion> recibir(
    String compraId,
    List<Llegada> llegadas, {
    String nota = '',
  }) async {
    final antes = compraDe(compraId);
    if (antes == null) return const RecepcionVacia();
    final indices = indicesDeLlegadas(antes, llegadas);
    if (indices.isEmpty) return const RecepcionVacia();
    final lineas = conLlegadas(antes, llegadas);
    for (final i in indices) {
      if (_buscar(lineas[i].productoId) == null) {
        return RecepcionSinProducto(lineas[i].producto);
      }
    }
    final despues = antes.conRecepcion(lineas, cuando: _ahora());
    final cambio = await _transacciones.enUna(
      () => _escribirRecepcion(antes, despues, indices, nota),
    );
    _ultimaRecepcion = cambio;
    _guardarEnMemoria(despues);
    return RecepcionRegistrada(despues, lineas: indices.length);
  }

  Future<_CambioRecepcion> _escribirRecepcion(
    Compra antes,
    Compra despues,
    List<int> indices,
    String nota,
  ) async {
    final anotacion = [
      if (despues.factura.isEmpty)
        'Pedido recibido'
      else
        'Factura ${despues.factura}',
      if (nota.isNotEmpty) nota,
    ].join(' · ');
    final productos = <({Producto antes, Producto despues})>[];
    final anotados = <Movimiento>[];
    for (final i in indices) {
      final linea = despues.lineas[i];
      final previo = _buscar(linea.productoId)!;
      await _existencias.actualizarProducto(
        previo.id,
        DatosProducto.desde(
          recibirLinea(previo, linea, proveedor: despues.proveedor),
        ),
      );
      productos.add((antes: previo, despues: _buscar(previo.id)!));
      final anotado = await _movimientos?.anotar(
        Movimiento(
          fecha: _ahora(),
          tipo: TipoMovimiento.entrada,
          productoId: linea.productoId,
          producto: linea.producto,
          forma: linea.forma,
          marca: linea.marca,
          proveedor: despues.proveedor,
          piezas: linea.piezasLlegadas,
          cantidad: linea.cantidadLlegada,
          nota: anotacion,
        ),
      );
      if (anotado != null) anotados.add(anotado);
    }
    await _repositorio.guardarRecepcion(despues);
    return (
      antes: antes,
      despues: despues,
      productos: productos,
      anotados: anotados,
    );
  }

  /// Takes the last reception back. Refused (false) when one of its
  /// products changed since, to not lose that change.
  Future<bool> deshacerRecepcion() async {
    final ultima = _ultimaRecepcion;
    if (ultima == null) return false;
    _ultimaRecepcion = null;
    notifyListeners();
    // Two lines of one product: its first "before" and its last "after".
    final antes = <String, Producto>{};
    final despues = <String, Producto>{};
    for (final p in ultima.productos) {
      antes.putIfAbsent(p.antes.id, () => p.antes);
      despues[p.despues.id] = p.despues;
    }
    for (final MapEntry(key: id, value: producto) in despues.entries) {
      if (_buscar(id) != producto) return false;
    }
    await _transacciones.enUna(() async {
      for (final producto in antes.values) {
        await _existencias.actualizarProducto(
          producto.id,
          DatosProducto.desde(producto),
        );
      }
      for (final anotado in ultima.anotados) {
        await _movimientos?.quitar(anotado);
      }
      await _repositorio.guardarRecepcion(ultima.antes);
    });
    _guardarEnMemoria(ultima.antes);
    return true;
  }

  /// Pays all or part of an invoice on credit. [entregado] is in the
  /// medio's currency; bolívares are turned into dollars at today's rate.
  Future<ResultadoPago> pagar(
    CuentaPorPagar cuenta, {
    required MedioPago medio,
    required int entregado,
    String referencia = '',
  }) async {
    final tasa = tasaDeHoy;
    final convertido = aDolares(entregado, medio.moneda, tasa);
    if (convertido == null) return const PagoSinTasa();
    final debe = cuentaDe(cuenta.compra.id)?.debe ?? cuenta.debe;
    // Bolívares round to the cent; one over the debt is paying it all.
    final redondeo = medio.moneda == Moneda.bolivares && convertido == debe + 1;
    final monto = redondeo ? debe : convertido;
    if (monto <= 0 || monto > debe) return PagoExcede(debe: debe);
    final guardado = await _repositorio.crearPago(
      Pago(
        compraId: cuenta.compra.id,
        fecha: _ahora(),
        medio: medio,
        monto: monto,
        entregado: entregado,
        tasa: medio.moneda == Moneda.bolivares ? tasa : null,
        referencia: referencia,
      ),
    );
    _ultimoPago = guardado;
    _pagos = [..._pagos, guardado];
    notifyListeners();
    return PagoRegistrado(guardado, debe: debe - monto);
  }

  Future<void> deshacerPago() async {
    final pago = _ultimoPago;
    if (pago == null) return;
    _ultimoPago = null;
    await _repositorio.borrarPago(pago.id);
    _pagos = [
      for (final p in _pagos)
        if (p.id != pago.id) p,
    ];
    notifyListeners();
  }

  /// Keeps invoices linked when a supplier is renamed.
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    await _repositorio.renombrarProveedor(anterior, nuevo);
    await cargar();
  }

  void _guardarEnMemoria(Compra compra) {
    _compras = _ordenar([
      for (final c in _compras)
        if (c.id == compra.id) compra else c,
    ]);
    notifyListeners();
  }

  static List<Compra> _ordenar(List<Compra> compras) =>
      [...compras]..sort((a, b) => b.fecha.compareTo(a.fecha));

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
