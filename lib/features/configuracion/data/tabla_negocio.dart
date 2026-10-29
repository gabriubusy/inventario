import 'package:drift/drift.dart';

/// One row: the shop's details. In the database so a backup carries them.
@DataClassName('FilaNegocio')
class Negocio extends Table {
  IntColumn get id => integer()();
  TextColumn get nombre => text()();
  TextColumn get rif => text()();
  TextColumn get direccion => text()();
  TextColumn get telefono => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
