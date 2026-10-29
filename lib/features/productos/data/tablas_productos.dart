import 'package:drift/drift.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lista_precio.dart';

@DataClassName('FilaProducto')
class Productos extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();

  /// Name without case or accents; unique, so two products can't clash.
  TextColumn get nombreClave => text().unique()();
  TextColumn get categoria => textEnum<Categoria>()();
  TextColumn get forma => textEnum<FormaConteo>()();
  IntColumn get minimo => integer()();
  TextColumn get imagenId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FilaLoteMarca')
class LotesMarca extends Table {
  TextColumn get productoId =>
      text().references(Productos, #id, onDelete: KeyAction.cascade)();

  /// Keeps the brands in the order the user typed them.
  IntColumn get orden => integer()();
  TextColumn get marca => text()();
  TextColumn get proveedor => text()();
  IntColumn get piezas => integer()();
  BoolColumn get piezaAbierta => boolean()();
  IntColumn get cantidad => integer()();
  IntColumn get precio => integer().nullable()();
  IntColumn get costo => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {productoId, orden};
}

/// A product's rule for Mayor or Especial (schema 8). [tipo] is `margen`
/// (valor in hundredths of a percent) or `fijo` (dollar hundredths).
@DataClassName('FilaReglaPrecio')
class ReglasPrecio extends Table {
  TextColumn get productoId =>
      text().references(Productos, #id, onDelete: KeyAction.cascade)();
  TextColumn get lista => textEnum<ListaPrecio>()();
  TextColumn get tipo => text()();
  IntColumn get valor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {productoId, lista};
}

@DataClassName('FilaPresentacion')
@TableIndex(name: 'presentaciones_codigo', columns: {#codigo})
class Presentaciones extends Table {
  TextColumn get productoId =>
      text().references(Productos, #id, onDelete: KeyAction.cascade)();
  IntColumn get orden => integer()();
  TextColumn get nombre => text()();
  IntColumn get factor => integer()();
  IntColumn get precio => integer()();
  TextColumn get codigo => text()();
  BoolColumn get predeterminada => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {productoId, orden};
}
