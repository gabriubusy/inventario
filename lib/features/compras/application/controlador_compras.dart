import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/core/transacciones.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/compras/domain/recibir_linea.dart';
import 'package:inventario/features/compras/domain/repositorio_compras.dart';
import 'package:inventario/features/compras/domain/resultados_compra.dart';
import 'package:inventario/features/compras/domain/resumen_cuentas.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';

typedef _CambioCompra = ({
  Compra compra,
  List<({Producto antes, Producto despues})> productos,
  List<Movimiento> anotados,
});

/// Supplier invoices (F2) and what is still owed on them (F10). A purchase
/// raises the stock and its lots' cost in one transaction.
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
  _CambioCompra? _ultimaCompra;
  Pago? _ultimoPago;

  DateTime get hoy => _ahora();
  int? get tasaDeHoy => _tasaDeHoy?.call();
  bool get puedeDeshacerCompra => _ultimaCompra != null;

  /// Newest first.
  List<Compra> get compras => _compras;

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

  Future<void> cargar() async {
    _compras = _ordenar(await _repositorio.obtenerCompras());
    _pagos = await _repositorio.obtenerPagos();
    notifyListeners();
  }

  /// Adds every line to its brand lot, notes the entries in the kardex and
  /// stores the invoice, all or nothing.
  Future<ResultadoCompra> registrar(Compra compra) async {
    for (final linea in compra.lineas) {
      if (_buscar(linea.productoId) == null) {
        return CompraSinProducto(linea.producto);
      }
    }
    final datos = Compra(
      fecha: _ahora(),
      proveedor: compra.proveedor,
      factura: compra.factura,
      lineas: compra.lineas,
      vence: compra.vence,
      medio: compra.medio,
      tasa: tasaDeHoy,
    );
    final cambio = await _transacciones.enUna(() => _escribir(datos));
    _ultimaCompra = cambio;
    _compras = _ordenar([..._compras, cambio.compra]);
    notifyListeners();
    return CompraRegistrada(cambio.compra);
  }

  Future<_CambioCompra> _escribir(Compra compra) async {
    final productos = <({Producto antes, Producto despues})>[];
    final anotados = <Movimiento>[];
    for (final linea in compra.lineas) {
      final antes = _buscar(linea.productoId)!;
      await _existencias.actualizarProducto(
        antes.id,
        DatosProducto.desde(
          recibirLinea(antes, linea, proveedor: compra.proveedor),
        ),
      );
      productos.add((antes: antes, despues: _buscar(antes.id)!));
      final anotado = await _movimientos?.anotar(
        Movimiento(
          fecha: compra.fecha,
          tipo: TipoMovimiento.entrada,
          productoId: linea.productoId,
          producto: linea.producto,
          forma: linea.forma,
          marca: linea.marca,
          proveedor: compra.proveedor,
          piezas: linea.piezas,
          cantidad: linea.cantidad,
          nota: compra.factura.isEmpty ? 'Compra' : 'Factura ${compra.factura}',
        ),
      );
      if (anotado != null) anotados.add(anotado);
    }
    final guardada = await _repositorio.crearCompra(compra);
    return (compra: guardada, productos: productos, anotados: anotados);
  }

  /// Takes the last purchase back. Refused (false) when one of its products
  /// changed since, to not lose that change.
  Future<bool> deshacerCompra() async {
    final ultima = _ultimaCompra;
    if (ultima == null) return false;
    _ultimaCompra = null;
    notifyListeners();
    for (final p in ultima.productos) {
      if (_buscar(p.despues.id) != p.despues) return false;
    }
    await _transacciones.enUna(() async {
      for (final p in ultima.productos.reversed) {
        await _existencias.actualizarProducto(
          p.antes.id,
          DatosProducto.desde(p.antes),
        );
      }
      for (final anotado in ultima.anotados) {
        await _movimientos?.quitar(anotado);
      }
      await _repositorio.borrarCompra(ultima.compra.id);
    });
    _compras = [
      for (final c in _compras)
        if (c.id != ultima.compra.id) c,
    ];
    _pagos = [
      for (final p in _pagos)
        if (p.compraId != ultima.compra.id) p,
    ];
    notifyListeners();
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

  static List<Compra> _ordenar(List<Compra> compras) =>
      [...compras]..sort((a, b) => b.fecha.compareTo(a.fecha));

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
