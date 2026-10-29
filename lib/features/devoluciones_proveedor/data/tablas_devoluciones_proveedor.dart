import 'package:drift/drift.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/motivo_devolucion.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Goods sent back to suppliers. The invoice is kept by id without a
/// foreign key, so undoing a purchase never fails over an old return.
@DataClassName('FilaDevolucionProveedor')
class DevolucionesProveedor extends Table {
  TextColumn get id => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get proveedor => text()();
  TextColumn get motivo => textEnum<MotivoDevolucion>()();
  TextColumn get compensacion => textEnum<Compensacion>()();
  TextColumn get compraId => text().nullable()();
  TextColumn get medio => textEnum<MedioPago>().nullable()();
  IntColumn get entregado => integer().nullable()();
  IntColumn get tasa => integer().nullable()();
  DateTimeColumn get repuesta => dateTime().nullable()();
  TextColumn get nota => text()();
  TextColumn get incidenciaId => text().nullable()();
  BoolColumn get sacada => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FilaLineaDevolucion')
class LineasDevolucion extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get devolucionId => text().references(
    DevolucionesProveedor,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get orden => integer()();
  TextColumn get productoId => text()();
  TextColumn get producto => text()();
  TextColumn get forma => textEnum<FormaConteo>()();
  TextColumn get marca => text()();
  IntColumn get piezas => integer()();
  IntColumn get cantidad => integer()();
  IntColumn get costo => integer()();
}
