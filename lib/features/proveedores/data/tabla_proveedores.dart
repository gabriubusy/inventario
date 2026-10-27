import 'package:drift/drift.dart';

@DataClassName('FilaProveedor')
class Proveedores extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();

  /// Name without case or accents; unique like the product's.
  TextColumn get nombreClave => text().unique()();
  TextColumn get rif => text()();
  TextColumn get telefono => text()();
  TextColumn get contacto => text()();
  TextColumn get notas => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
