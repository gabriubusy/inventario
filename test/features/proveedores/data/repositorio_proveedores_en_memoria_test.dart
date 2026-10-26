import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/domain/resultado_guardar_proveedor.dart';

void main() {
  const existente = Proveedor(id: 'v1', nombre: 'Distribuidora 1');
  late RepositorioProveedoresEnMemoria repositorio;

  setUp(() => repositorio = RepositorioProveedoresEnMemoria([existente]));

  test('creates a supplier with a free id', () async {
    final resultado = await repositorio.crear(
      const DatosProveedor(nombre: 'Lácteos 1', telefono: '0414'),
    );
    final proveedor = (resultado as ProveedorGuardado).proveedor;
    expect(proveedor.nombre, 'Lácteos 1');
    expect(proveedor.telefono, '0414');
    expect(proveedor.id, isNot(existente.id));
    expect(await repositorio.obtenerTodos(), [existente, proveedor]);
  });

  test('rejects a name already used, ignoring case and accents', () async {
    final resultado = await repositorio.crear(
      const DatosProveedor(nombre: ' DISTRIBUIDORA 1 '),
    );
    expect(resultado, isA<NombreProveedorRepetido>());
  });

  test('updates a supplier keeping its id', () async {
    final resultado = await repositorio.actualizar(
      'v1',
      const DatosProveedor(nombre: 'Distribuidora Uno', notas: 'Lunes'),
    );
    expect(
      (resultado as ProveedorGuardado).proveedor,
      const Proveedor(id: 'v1', nombre: 'Distribuidora Uno', notas: 'Lunes'),
    );
    expect(await repositorio.obtenerTodos(), [resultado.proveedor]);
  });

  test('an update may keep its own name but not take another', () async {
    await repositorio.crear(const DatosProveedor(nombre: 'Lácteos 1'));
    final mismo = await repositorio.actualizar(
      'v1',
      const DatosProveedor(nombre: 'distribuidora 1'),
    );
    final ajeno = await repositorio.actualizar(
      'v1',
      const DatosProveedor(nombre: 'Lacteos 1'),
    );
    expect(mismo, isA<ProveedorGuardado>());
    expect(ajeno, isA<NombreProveedorRepetido>());
  });
}
