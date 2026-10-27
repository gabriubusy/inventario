import 'package:drift/drift.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Product name, amounts and rate are copied at the moment, so history
/// doesn't change when the product, its price or the rate do.
@DataClassName('FilaMovimiento')
@TableIndex(name: 'movimientos_fecha', columns: {#fecha})
@TableIndex(name: 'movimientos_producto', columns: {#productoId})
class Movimientos extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get tipo => textEnum<TipoMovimiento>()();
  TextColumn get productoId => text()();
  TextColumn get producto => text()();
  TextColumn get forma => textEnum<FormaConteo>()();
  TextColumn get marca => text()();
  TextColumn get proveedor => text()();
  IntColumn get piezas => integer()();
  IntColumn get cantidad => integer()();
  IntColumn get importe => integer().nullable()();
  IntColumn get costo => integer().nullable()();
  BoolColumn get abrioPieza => boolean()();
  BoolColumn get anulada => boolean()();
  IntColumn get tasa => integer().nullable()();
  TextColumn get nota => text()();
  TextColumn get origenId => text().nullable()();

  /// The paid ticket a sale line belongs to (schema 3).
  TextColumn get ventaId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
