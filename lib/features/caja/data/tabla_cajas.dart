import 'package:drift/drift.dart';

/// One working day of the till. The closing count is kept as text,
/// "medio=monto;…", since the ways of paying may grow.
@DataClassName('FilaCaja')
class Cajas extends Table {
  TextColumn get id => text()();
  DateTimeColumn get abierta => dateTime()();
  IntColumn get fondoDolares => integer()();
  IntColumn get fondoBolivares => integer()();
  DateTimeColumn get cerrada => dateTime().nullable()();
  TextColumn get contado => text()();
  TextColumn get nota => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
