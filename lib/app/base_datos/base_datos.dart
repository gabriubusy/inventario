import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/data/tabla_cajas.dart';
import 'package:inventario/features/compras/data/tabla_compras.dart';
import 'package:inventario/features/configuracion/data/tabla_negocio.dart';
import 'package:inventario/features/devoluciones_proveedor/data/tablas_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/gastos/data/tabla_gastos.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';
import 'package:inventario/features/incidencias/data/tabla_incidencias.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/movimientos/data/tabla_movimientos.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/data/tablas_productos.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';
import 'package:inventario/features/proveedores/data/tabla_proveedores.dart';
import 'package:inventario/features/salidas/data/tablas_ventas.dart';

part 'base_datos.g.dart';

/// The app's single SQLite file. Each feature declares its tables in its
/// own data/ folder; this only puts them together.
@DriftDatabase(
  tables: [
    Productos,
    LotesMarca,
    Presentaciones,
    Proveedores,
    Incidencias,
    Movimientos,
    Compras,
    LineasCompra,
    Pagos,
    Ventas,
    PagosVenta,
    Cajas,
    Gastos,
    DevolucionesProveedor,
    LineasDevolucion,
    Negocio,
    ReglasPrecio,
  ],
)
class BaseDatos extends _$BaseDatos {
  BaseDatos(super.ejecutor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, desde, _) async {
      // 2: purchases and payments to suppliers.
      if (desde < 2) {
        await m.createTable(compras);
        await m.createTable(lineasCompra);
        await m.createTable(pagos);
      }
      // 3: tickets with several products and how they were paid.
      if (desde < 3) {
        await m.createTable(ventas);
        await m.createIndex(ventasFecha);
        await m.createTable(pagosVenta);
        await m.addColumn(movimientos, movimientos.ventaId);
      }
      // 4: the till and the business's expenses and other income.
      if (desde < 4) {
        await m.createTable(cajas);
        await m.createTable(gastos);
      }
      // 5: how a customer return's money was handed back.
      if (desde < 5) {
        await m.addColumn(movimientos, movimientos.medioReembolso);
      }
      // 6: goods sent back to suppliers.
      if (desde < 6) {
        await m.createTable(devolucionesProveedor);
        await m.createTable(lineasDevolucion);
      }
      // 7: the shop's details, so a backup carries them.
      if (desde < 7) {
        await m.createTable(negocio);
      }
      // 8: Mayor and Especial price lists, and the list each sale used.
      if (desde < 8) {
        await m.createTable(reglasPrecio);
        // A database older than 3 got today's ventas, list column included.
        if (desde >= 3) await m.addColumn(ventas, ventas.lista);
      }
      // 9: when a sale was cancelled, for the till open at that moment.
      if (desde < 9) {
        await m.addColumn(movimientos, movimientos.anuladaEl);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // WAL survives a crash mid-write better; the browser build can't use it.
      if (!kIsWeb) await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
