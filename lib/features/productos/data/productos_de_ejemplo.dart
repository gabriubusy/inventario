import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

// Development-only sample stock; remove once products live in the database.
const List<Producto> productosDeEjemplo = [
  Producto(
    id: '1',
    nombre: 'Bistec de res',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 18500,
        precio: 750,
      ),
    ],
  ),
  Producto(
    id: '2',
    nombre: 'Carne molida',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 8000,
    lotes: [
      LoteMarca(
        marca: 'Propia',
        proveedor: 'Frigorífico 1',
        cantidad: 3800,
        precio: 620,
      ),
    ],
  ),
  Producto(
    id: '3',
    nombre: 'Chuleta ahumada',
    categoria: Categoria.carnes,
    forma: FormaConteo.porKilo,
    minimo: 3000,
  ),
  Producto(
    id: '4',
    nombre: 'Pechuga de pollo',
    categoria: Categoria.aves,
    forma: FormaConteo.porKilo,
    minimo: 10000,
    lotes: [
      LoteMarca(
        marca: 'Marca G',
        proveedor: 'Avícola 1',
        cantidad: 14000,
        precio: 590,
      ),
    ],
  ),
  Producto(
    id: '5',
    nombre: 'Jamón de pierna',
    categoria: Categoria.embutidos,
    forma: FormaConteo.piezasYKilos,
    minimo: 4,
    lotes: [
      LoteMarca(
        marca: 'Marca F',
        proveedor: 'Distribuidora 1',
        piezas: 3,
        piezaAbierta: true,
        cantidad: 16400,
        precio: 980,
      ),
    ],
  ),
  Producto(
    id: '6',
    nombre: 'Mortadela',
    categoria: Categoria.embutidos,
    forma: FormaConteo.piezasYKilos,
    minimo: 1,
    lotes: [
      LoteMarca(
        marca: 'Marca H',
        proveedor: 'Distribuidora 2',
        piezas: 2,
        cantidad: 6100,
        precio: 450,
      ),
    ],
  ),
  Producto(
    id: '7',
    nombre: 'Salchicha de pollo',
    categoria: Categoria.embutidos,
    forma: FormaConteo.porUnidad,
    minimo: 20,
    lotes: [
      LoteMarca(
        marca: 'Marca D',
        proveedor: 'Distribuidora 2',
        cantidad: 18,
        precio: 210,
      ),
      LoteMarca(
        marca: 'Marca E',
        proveedor: 'Distribuidora 2',
        cantidad: 12,
        precio: 240,
      ),
    ],
  ),
  Producto(
    id: '8',
    nombre: 'Queso blanco duro',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 5,
    lotes: [
      LoteMarca(
        marca: 'Marca A',
        proveedor: 'Distribuidora 1',
        piezas: 10,
        cantidad: 8200,
        precio: 520,
      ),
      LoteMarca(
        marca: 'Marca B',
        proveedor: 'Distribuidora 2',
        piezas: 14,
        piezaAbierta: true,
        cantidad: 11000,
        precio: 560,
      ),
    ],
  ),
  Producto(
    id: '9',
    nombre: 'Queso guayanés',
    categoria: Categoria.quesos,
    forma: FormaConteo.piezasYKilos,
    minimo: 3,
  ),
];
