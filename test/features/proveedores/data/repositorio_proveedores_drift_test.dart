import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/base_datos/base_datos.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_drift.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

void main() {
  const norte = DatosProveedor(
    nombre: 'Distribuidora Norte',
    rif: 'J-12345678-9',
    telefono: '0414-1234567',
  );
  late BaseDatos db;
  late RepositorioProveedoresDrift repositorio;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    repositorio = RepositorioProveedoresDrift(db);
  });

  tearDown(() => db.close());

  test('a supplier is saved and comes back', () async {
    final creado = await repositorio.crear(norte);
    expect(creado, isA<ProveedorGuardado>());
    expect(await repositorio.obtenerTodos(), [
      (creado as ProveedorGuardado).proveedor,
    ]);
  });

  test('refuses a name already used, also when editing another', () async {
    await repositorio.crear(norte);
    final sur = await repositorio.crear(
      const DatosProveedor(nombre: 'Lácteos Sur'),
    );
    expect(
      await repositorio.crear(
        const DatosProveedor(nombre: 'distribuidora NORTE'),
      ),
      isA<NombreProveedorRepetido>(),
    );
    expect(
      await repositorio.actualizar(
        (sur as ProveedorGuardado).proveedor.id,
        norte,
      ),
      isA<NombreProveedorRepetido>(),
    );
  });

  test('editing keeps its own name allowed', () async {
    final creado = await repositorio.crear(norte) as ProveedorGuardado;
    final editado = await repositorio.actualizar(
      creado.proveedor.id,
      const DatosProveedor(nombre: 'Distribuidora Norte', notas: 'Martes'),
    );
    expect(editado, isA<ProveedorGuardado>());
    expect((await repositorio.obtenerTodos()).single.notas, 'Martes');
  });
}
