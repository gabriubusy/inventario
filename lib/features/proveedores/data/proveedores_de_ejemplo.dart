import 'package:inventario/features/proveedores/domain/proveedor.dart';

// Development-only suppliers matching the sample products' brand lots.
const List<Proveedor> proveedoresDeEjemplo = [
  Proveedor(id: '1', nombre: 'Avícola 1', telefono: '0412-000.00.00'),
  Proveedor(
    id: '2',
    nombre: 'Distribuidora 1',
    rif: 'J-00000000-0',
    telefono: '0414-000.00.00',
    notas: 'Pasa lunes y jueves',
  ),
  Proveedor(
    id: '3',
    nombre: 'Distribuidora 2',
    rif: 'J-00000000-2',
    telefono: '0424-000.00.00',
  ),
  Proveedor(id: '4', nombre: 'Frigorífico 1', telefono: '0416-000.00.00'),
];
