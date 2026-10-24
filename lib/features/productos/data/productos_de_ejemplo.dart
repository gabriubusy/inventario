import 'package:inventario/core/unidad.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/producto.dart';

// Development-only sample stock; remove once products live in the database.
const List<Producto> productosDeEjemplo = [
  Producto(
    id: '1',
    nombre: 'Bistec de res',
    categoria: Categoria.carnes,
    unidad: UnidadBase.kg,
    existencia: 18500,
    minimo: 8000,
  ),
  Producto(
    id: '2',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    unidad: UnidadBase.kg,
    existencia: 3800,
    minimo: 8000,
  ),
  Producto(
    id: '3',
    nombre: 'Chuleta ahumada',
    categoria: Categoria.carnes,
    unidad: UnidadBase.kg,
    existencia: 0,
    minimo: 3000,
  ),
  Producto(
    id: '4',
    nombre: 'Pechuga de pollo',
    categoria: Categoria.aves,
    unidad: UnidadBase.kg,
    existencia: 14000,
    minimo: 10000,
  ),
  Producto(
    id: '5',
    nombre: 'Jamón de pierna',
    categoria: Categoria.embutidos,
    unidad: UnidadBase.kg,
    existencia: 1200,
    minimo: 5000,
  ),
  Producto(
    id: '6',
    nombre: 'Mortadela',
    categoria: Categoria.embutidos,
    unidad: UnidadBase.kg,
    existencia: 2500,
    minimo: 4000,
  ),
  Producto(
    id: '7',
    nombre: 'Salchicha de pollo',
    categoria: Categoria.embutidos,
    unidad: UnidadBase.unidad,
    existencia: 6,
    minimo: 20,
  ),
  Producto(
    id: '8',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    unidad: UnidadBase.kg,
    existencia: 9400,
    minimo: 6000,
  ),
  Producto(
    id: '9',
    nombre: 'Queso guayanés',
    categoria: Categoria.quesos,
    unidad: UnidadBase.kg,
    existencia: 0,
    minimo: 4000,
  ),
];
