import 'package:drift/drift.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Product and supplier are kept by value, like on paper, so an incident
/// still reads right after the product is renamed or deleted.
@DataClassName('FilaIncidencia')
class Incidencias extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get proveedor => text()();
  TextColumn get productoId => text()();
  TextColumn get producto => text()();
  TextColumn get forma => textEnum<FormaConteo>()();
  TextColumn get marca => text()();
  TextColumn get tipo => textEnum<TipoIncidencia>()();
  IntColumn get piezas => integer()();
  IntColumn get cantidad => integer()();
  TextColumn get nota => text()();
  BoolColumn get sacada => boolean()();
  TextColumn get respuesta => textEnum<RespuestaProveedor>().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
