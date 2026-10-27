import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/tipo_incidencia.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';

/// Something wrong with goods from a supplier, open until it answers.
class Incidencia {
  const Incidencia({
    required this.id,
    required this.fecha,
    required this.proveedor,
    required this.productoId,
    required this.producto,
    required this.forma,
    required this.marca,
    required this.tipo,
    this.piezas = 0,
    required this.cantidad,
    this.nota = '',
    this.sacada = false,
    this.respuesta,
  });

  Incidencia.desde(String id, DatosIncidencia datos)
    : this(
        id: id,
        fecha: datos.fecha,
        proveedor: datos.proveedor,
        productoId: datos.productoId,
        producto: datos.producto,
        forma: datos.forma,
        marca: datos.marca,
        tipo: datos.tipo,
        piezas: datos.piezas,
        cantidad: datos.cantidad,
        nota: datos.nota,
        sacada: datos.sacada,
      );

  /// Open incidents older than this are shown as overdue, to chase them up.
  static const diasParaReclamar = 7;

  final String id;
  final DateTime fecha;
  final String proveedor;
  final String productoId;
  final String producto;
  final FormaConteo forma;
  final String marca;
  final TipoIncidencia tipo;
  final int piezas;
  final int cantidad;
  final String nota;
  final bool sacada;

  /// Null while the supplier has not answered.
  final RespuestaProveedor? respuesta;

  bool get abierta => respuesta == null;

  int diasAbierta(DateTime hoy) => diasEntre(fecha, hoy);

  bool atrasada(DateTime hoy) => abierta && diasAbierta(hoy) > diasParaReclamar;

  /// A null [respuesta] reopens it.
  Incidencia conRespuesta(RespuestaProveedor? respuesta) =>
      _copia(respuesta: respuesta, proveedor: proveedor);

  Incidencia conProveedor(String proveedor) =>
      _copia(respuesta: respuesta, proveedor: proveedor);

  Incidencia _copia({
    required RespuestaProveedor? respuesta,
    required String proveedor,
  }) => Incidencia(
    id: id,
    fecha: fecha,
    proveedor: proveedor,
    productoId: productoId,
    producto: producto,
    forma: forma,
    marca: marca,
    tipo: tipo,
    piezas: piezas,
    cantidad: cantidad,
    nota: nota,
    sacada: sacada,
    respuesta: respuesta,
  );

  @override
  bool operator ==(Object other) =>
      other is Incidencia &&
      other.id == id &&
      other.fecha == fecha &&
      other.proveedor == proveedor &&
      other.productoId == productoId &&
      other.producto == producto &&
      other.forma == forma &&
      other.marca == marca &&
      other.tipo == tipo &&
      other.piezas == piezas &&
      other.cantidad == cantidad &&
      other.nota == nota &&
      other.sacada == sacada &&
      other.respuesta == respuesta;

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    proveedor,
    productoId,
    producto,
    forma,
    marca,
    tipo,
    piezas,
    cantidad,
    nota,
    sacada,
    respuesta,
  );
}
