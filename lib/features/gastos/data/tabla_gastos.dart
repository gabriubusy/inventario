import 'package:drift/drift.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';

@DataClassName('FilaGasto')
class Gastos extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get categoria => textEnum<CategoriaGasto>()();
  TextColumn get medio => textEnum<MedioPago>()();
  IntColumn get monto => integer()();
  IntColumn get tasa => integer().nullable()();
  TextColumn get nota => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
