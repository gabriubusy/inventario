import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/proveedores/domain/datos_proveedor.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';

void main() {
  const proveedor = Proveedor(
    id: 'v1',
    nombre: 'Distribuidora 1',
    telefono: '0414-000.00.00',
  );

  test('optional fields start empty', () {
    expect(proveedor.rif, '');
    expect(proveedor.contacto, '');
    expect(proveedor.notas, '');
  });

  test('suppliers with the same data are equal', () {
    expect(proveedor, proveedor.copyWith());
    expect(proveedor.hashCode, proveedor.copyWith().hashCode);
    expect(proveedor, isNot(proveedor.copyWith(notas: 'Pasa los lunes')));
  });

  test('form data with the same values are equal', () {
    expect(
      const DatosProveedor(nombre: 'A', rif: 'J-1'),
      const DatosProveedor(nombre: 'A', rif: 'J-1'),
    );
    expect(
      const DatosProveedor(nombre: 'A'),
      isNot(const DatosProveedor(nombre: 'B')),
    );
  });
}
