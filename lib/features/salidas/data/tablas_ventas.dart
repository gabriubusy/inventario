import 'package:drift/drift.dart';
import 'package:inventario/core/medio_pago.dart';

/// A paid ticket; its products are the sale movements with its id.
@DataClassName('FilaVenta')
@TableIndex(name: 'ventas_fecha', columns: {#fecha})
class Ventas extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get total => integer()();
  IntColumn get tasa => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FilaPagoVenta')
class PagosVenta extends Table {
  TextColumn get ventaId =>
      text().references(Ventas, #id, onDelete: KeyAction.cascade)();

  /// Keeps the payments of a mixed sale in the order they were added.
  IntColumn get orden => integer()();
  TextColumn get medio => textEnum<MedioPago>()();

  /// Hundredths of the payment's own currency.
  IntColumn get monto => integer()();
  TextColumn get referencia => text()();

  @override
  Set<Column<Object>> get primaryKey => {ventaId, orden};
}
