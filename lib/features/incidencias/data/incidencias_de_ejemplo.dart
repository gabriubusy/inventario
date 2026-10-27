import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Development-only incidents on the sample products, dated back from [hoy].
List<Incidencia> incidenciasDeEjemplo(DateTime hoy) => [
  Incidencia(
    id: 'e1',
    fecha: hoy.subtract(const Duration(days: 24)),
    proveedor: 'Distribuidora 1',
    productoId: '8',
    producto: 'Queso blanco duro',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca A',
    tipo: TipoIncidencia.malEstado,
    piezas: 1,
    cantidad: 900,
    sacada: true,
    respuesta: RespuestaProveedor.descuento,
  ),
  Incidencia(
    id: 'e2',
    fecha: hoy.subtract(const Duration(days: 9)),
    proveedor: 'Distribuidora 1',
    productoId: '5',
    producto: 'Jamón de pierna',
    forma: FormaConteo.piezasYKilos,
    marca: 'Marca F',
    tipo: TipoIncidencia.faltante,
    cantidad: 800,
    nota: 'La factura dice 4 kg y pesó 3,2 kg',
  ),
  Incidencia(
    id: 'e3',
    fecha: hoy.subtract(const Duration(days: 3)),
    proveedor: 'Frigorífico 1',
    productoId: '2',
    producto: 'Carne molida',
    forma: FormaConteo.porKilo,
    marca: 'Propia',
    tipo: TipoIncidencia.vencido,
    cantidad: 1500,
    sacada: true,
  ),
];
