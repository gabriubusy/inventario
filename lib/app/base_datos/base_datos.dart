import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/data/tabla_compras.dart';
import 'package:inventario/features/incidencias/data/tabla_incidencias.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/movimientos/data/tabla_movimientos.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/data/tablas_productos.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
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
  ],
)
class BaseDatos extends _$BaseDatos {
  BaseDatos(super.ejecutor);

  @override
  int get schemaVersion => 3;

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
        await m.createTable(pagosVenta);
        await m.addColumn(movimientos, movimientos.ventaId);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // WAL survives a crash mid-write better; the browser build can't use it.
      if (!kIsWeb) await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
