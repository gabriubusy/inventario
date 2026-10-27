import 'package:inventario/core/dinero.dart';
import 'package:inventario/core/fechas.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/core/texto.dart';
import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';
import 'package:inventario/features/compras/domain/pago.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/gastos/domain/gasto.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/textos_producto.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';

/// Everything a report can draw from.
typedef DatosReportes = ({
  List<Movimiento> movimientos,
  List<Producto> productos,
  List<CuentaPorPagar> cuentas,
  List<Pago> pagos,
  List<Gasto> gastos,
});

Reporte construirReporte(
  TipoReporte tipo,
  PeriodoReporte periodo,
  DatosReportes datos,
  DateTime hoy,
) {
  final ventas = [
    for (final m in datos.movimientos)
      if (m.tipo == TipoMovimiento.venta &&
          !m.anulada &&
          periodo.incluye(m.fecha, hoy))
        m,
  ];
  final gastos = [
    for (final g in datos.gastos)
      if (periodo.incluye(g.fecha, hoy)) g,
  ];
  return switch (tipo) {
    TipoReporte.ventas => _ventas(ventas, hoy),
    TipoReporte.ganancia => _ganancia(ventas, gastos),
    TipoReporte.masVendidos => _masVendidos(ventas),
    TipoReporte.inventario => _inventario(datos.productos),
    TipoReporte.cuentas => _cuentas(datos, periodo, hoy),
    TipoReporte.gastos => _gastos(gastos),
  };
}

const _dinero = formatearDolares;

String _tickets(Iterable<Movimiento> lineas) {
  final tickets = {for (final l in lineas) l.ventaId ?? l.id}.length;
  return formatDecimal(tickets, decimales: 0);
}

int _suma(Iterable<Movimiento> lineas, int? Function(Movimiento) valor) =>
    lineas.fold(0, (total, l) => total + (valor(l) ?? 0));

Reporte _ventas(List<Movimiento> ventas, DateTime hoy) {
  final porDia = <DateTime, List<Movimiento>>{};
  for (final v in ventas) {
    final dia = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
    (porDia[dia] ??= []).add(v);
  }
  final dias = porDia.keys.toList()..sort((a, b) => b.compareTo(a));
  final total = _suma(ventas, (m) => m.importe);
  final tickets = {for (final l in ventas) l.ventaId ?? l.id}.length;
  DateTime? mejor;
  for (final d in dias) {
    if (mejor == null ||
        _suma(porDia[d]!, (m) => m.importe) >
            _suma(porDia[mejor]!, (m) => m.importe)) {
      mejor = d;
    }
  }
  return Reporte(
    titulo: 'Ventas',
    cifras: [
      (titulo: 'Vendido', valor: _dinero(total), detalle: ''),
      (
        titulo: 'Tickets',
        valor: formatDecimal(tickets, decimales: 0),
        detalle: tickets == 0
            ? ''
            : 'Promedio ${_dinero(dividirRedondeando(total, tickets))}',
      ),
      (
        titulo: 'Mejor día',
        valor: mejor == null ? '—' : formatearFechaCorta(mejor, hoy),
        detalle: mejor == null
            ? ''
            : _dinero(_suma(porDia[mejor]!, (m) => m.importe)),
      ),
    ],
    columnas: const ['Día', 'Tickets', 'Productos', 'Vendido', 'En Bs'],
    numericas: const {1, 2, 3, 4},
    filas: [
      for (final d in dias)
        [
          formatearFechaLarga(d),
          _tickets(porDia[d]!),
          formatDecimal(porDia[d]!.length, decimales: 0),
          _dinero(_suma(porDia[d]!, (m) => m.importe)),
          formatearBolivares(
            _suma(
              porDia[d]!,
              (m) => m.tasa == null || m.importe == null
                  ? null
                  : dividirRedondeando(m.importe! * m.tasa!, 100),
            ),
          ),
        ],
    ],
  );
}

Map<String, List<Movimiento>> _porProducto(List<Movimiento> lineas) {
  final grupos = <String, List<Movimiento>>{};
  for (final l in lineas) {
    (grupos[l.productoId] ??= []).add(l);
  }
  return grupos;
}

int _enDolares(Iterable<Gasto> gastos) =>
    gastos.fold(0, (total, g) => total + (g.enDolares ?? 0));

Reporte _ganancia(List<Movimiento> ventas, List<Gasto> gastos) {
  final vendido = _suma(ventas, (m) => m.importe);
  final costo = _suma(ventas, (m) => m.costo);
  final gastado = _enDolares(gastos.where((g) => !g.esIngreso));
  final ganancia = vendido - costo - gastado;
  final sinCosto = ventas.where((m) => m.costo == null).length;
  String margen(int venta, int c) => venta == 0
      ? '—'
      : '${formatDecimal(dividirRedondeando((venta - c) * 1000, venta), decimales: 1)} %';
  final filas = [
    for (final grupo in _porProducto(ventas).values)
      (
        nombre: grupo.first.producto,
        vendido: _suma(grupo, (m) => m.importe),
        costo: _suma(grupo, (m) => m.costo),
      ),
  ]..sort((a, b) => (b.vendido - b.costo).compareTo(a.vendido - a.costo));
  return Reporte(
    titulo: 'Ganancia',
    cifras: [
      (titulo: 'Vendido', valor: _dinero(vendido), detalle: ''),
      (
        titulo: 'Costo de lo vendido',
        valor: _dinero(costo),
        detalle: sinCosto == 0 ? '' : '$sinCosto ventas sin costo',
      ),
      (titulo: 'Gastos', valor: _dinero(gastado), detalle: ''),
      (
        titulo: 'Ganancia',
        valor: _dinero(ganancia),
        detalle: vendido == 0
            ? ''
            : '${margen(vendido, costo + gastado)} de lo vendido',
      ),
    ],
    columnas: const ['Producto', 'Vendido', 'Costo', 'Margen', 'Ganancia'],
    numericas: const {1, 2, 3, 4},
    filas: [
      for (final f in filas)
        [
          f.nombre,
          _dinero(f.vendido),
          _dinero(f.costo),
          margen(f.vendido, f.costo),
          _dinero(f.vendido - f.costo),
        ],
    ],
  );
}

Reporte _masVendidos(List<Movimiento> ventas) {
  final total = _suma(ventas, (m) => m.importe);
  final grupos = _porProducto(ventas).values.toList()
    ..sort(
      (a, b) =>
          _suma(b, (m) => m.importe).compareTo(_suma(a, (m) => m.importe)),
    );
  return Reporte(
    titulo: 'Más vendidos',
    cifras: [
      (
        titulo: 'Productos vendidos',
        valor: formatDecimal(grupos.length, decimales: 0),
        detalle: '',
      ),
      (
        titulo: 'El que más',
        valor: grupos.isEmpty ? '—' : grupos.first.first.producto,
        detalle: grupos.isEmpty
            ? ''
            : _dinero(_suma(grupos.first, (m) => m.importe)),
      ),
    ],
    columnas: const [
      'Producto',
      'Cantidad',
      'Tickets',
      'Vendido',
      '% del total',
    ],
    numericas: const {1, 2, 3, 4},
    filas: [
      for (final grupo in grupos)
        [
          grupo.first.producto,
          grupo.first.forma.unidad.formatear(_suma(grupo, (m) => m.cantidad)),
          _tickets(grupo),
          _dinero(_suma(grupo, (m) => m.importe)),
          total == 0
              ? '—'
              : '${formatDecimal(dividirRedondeando(_suma(grupo, (m) => m.importe) * 1000, total), decimales: 1)} %',
        ],
    ],
  );
}

Reporte _inventario(List<Producto> productos) {
  int valor(Producto p, int? Function(int? costo, int? precio) por) =>
      p.lotes.fold(
        0,
        (total, l) =>
            total +
            dividirRedondeando(
              (por(l.costo, l.precio) ?? 0) * l.cantidad,
              p.forma.unidad.fraccionesPorUnidad,
            ),
      );
  final filas = [
    for (final p in productos)
      if (p.tieneExistencias)
        (
          producto: p,
          costo: valor(p, (c, _) => c),
          precio: valor(p, (_, pr) => pr),
        ),
  ]..sort((a, b) => b.costo.compareTo(a.costo));
  final alCosto = filas.fold(0, (t, f) => t + f.costo);
  final aPrecio = filas.fold(0, (t, f) => t + f.precio);
  final sinCosto = filas.where(
    (f) => f.producto.lotes.any((l) => l.tieneExistencia && l.costo == null),
  );
  return Reporte(
    titulo: 'Inventario valorizado',
    cifras: [
      (
        titulo: 'Valor al costo',
        valor: _dinero(alCosto),
        detalle: sinCosto.isEmpty ? '' : '${sinCosto.length} sin costo',
      ),
      (titulo: 'Valor a precio', valor: _dinero(aPrecio), detalle: ''),
      (
        titulo: 'Ganancia posible',
        valor: _dinero(aPrecio - alCosto),
        detalle: '',
      ),
    ],
    columnas: const ['Producto', 'Hay', 'Al costo', 'A precio'],
    numericas: const {1, 2, 3},
    filas: [
      for (final f in filas)
        [
          f.producto.nombre,
          textoStock(f.producto),
          _dinero(f.costo),
          _dinero(f.precio),
        ],
    ],
  );
}

Reporte _cuentas(DatosReportes datos, PeriodoReporte periodo, DateTime hoy) {
  final pendientes = datos.cuentas.where((c) => c.debe > 0).toList();
  final porProveedor = <String, List<CuentaPorPagar>>{};
  for (final c in pendientes) {
    (porProveedor[normalizarParaBusqueda(c.compra.proveedor)] ??= []).add(c);
  }
  int suma(Iterable<CuentaPorPagar> c, int Function(CuentaPorPagar) v) =>
      c.fold(0, (t, x) => t + v(x));
  final vencidas = pendientes.where(
    (c) => c.estado(hoy) == EstadoCuenta.vencida,
  );
  final pagado = datos.pagos
      .where((p) => periodo.incluye(p.fecha, hoy))
      .fold(0, (t, p) => t + p.monto);
  final grupos = porProveedor.values.toList()
    ..sort((a, b) => suma(b, (c) => c.debe).compareTo(suma(a, (c) => c.debe)));
  return Reporte(
    titulo: 'Cuentas por pagar',
    cifras: [
      (
        titulo: 'Debemos',
        valor: _dinero(suma(pendientes, (c) => c.debe)),
        detalle: '',
      ),
      (
        titulo: 'Vencido',
        valor: _dinero(suma(vencidas, (c) => c.debe)),
        detalle: '${vencidas.length} facturas',
      ),
      (titulo: 'Pagado en el periodo', valor: _dinero(pagado), detalle: ''),
    ],
    columnas: const ['Proveedor', 'Facturas', 'Total', 'Abonado', 'Debe'],
    numericas: const {1, 2, 3, 4},
    filas: [
      for (final g in grupos)
        [
          g.first.compra.proveedor,
          formatDecimal(g.length, decimales: 0),
          _dinero(suma(g, (c) => c.compra.total)),
          _dinero(suma(g, (c) => c.abonado)),
          _dinero(suma(g, (c) => c.debe)),
        ],
    ],
  );
}

Reporte _gastos(List<Gasto> gastos) {
  final porCategoria = <CategoriaGasto, List<Gasto>>{};
  for (final g in gastos) {
    (porCategoria[g.categoria] ??= []).add(g);
  }
  final grupos = porCategoria.entries.toList()
    ..sort((a, b) => _enDolares(b.value).compareTo(_enDolares(a.value)));
  final soloGastos = grupos.where((e) => !e.key.esIngreso);
  return Reporte(
    titulo: 'Gastos',
    cifras: [
      (
        titulo: 'Gastos',
        valor: _dinero(_enDolares(gastos.where((g) => !g.esIngreso))),
        detalle: '',
      ),
      (
        titulo: 'Otros ingresos',
        valor: _dinero(_enDolares(gastos.where((g) => g.esIngreso))),
        detalle: '',
      ),
      (
        titulo: 'Mayor categoría',
        valor: soloGastos.isEmpty ? '—' : soloGastos.first.key.etiqueta,
        detalle: soloGastos.isEmpty
            ? ''
            : _dinero(_enDolares(soloGastos.first.value)),
      ),
    ],
    columnas: const ['Categoría', 'Tipo', 'Movimientos', 'Total en \$'],
    numericas: const {2, 3},
    filas: [
      for (final e in grupos)
        [
          e.key.etiqueta,
          e.key.esIngreso ? 'Ingreso' : 'Gasto',
          formatDecimal(e.value.length, decimales: 0),
          _dinero(_enDolares(e.value)),
        ],
    ],
  );
}
