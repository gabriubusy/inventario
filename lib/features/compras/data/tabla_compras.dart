import 'package:drift/drift.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Supplier invoices. The supplier is kept by name, like brand lots.
@DataClassName('FilaCompra')
class Compras extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get proveedor => text()();
  TextColumn get factura => text()();
  DateTimeColumn get vence => dateTime().nullable()();
  TextColumn get medio => textEnum<MedioPago>().nullable()();
  IntColumn get tasa => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Invoice lines; product name and way of counting kept by value so an old
/// invoice still reads right after the product changes.
@DataClassName('FilaLineaCompra')
class LineasCompra extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get compraId =>
      text().references(Compras, #id, onDelete: KeyAction.cascade)();
  IntColumn get orden => integer()();
  TextColumn get productoId => text()();
  TextColumn get producto => text()();
  TextColumn get forma => textEnum<FormaConteo>()();
  TextColumn get marca => text()();
  IntColumn get piezas => integer()();
  IntColumn get cantidad => integer()();
  IntColumn get costo => integer()();
}

@DataClassName('FilaPago')
class Pagos extends Table {
  TextColumn get id => text()();
  TextColumn get compraId =>
      text().references(Compras, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get medio => textEnum<MedioPago>()();
  IntColumn get monto => integer()();
  IntColumn get entregado => integer()();
  IntColumn get tasa => integer().nullable()();
  TextColumn get referencia => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
