import 'package:flutter/foundation.dart';
import 'package:inventario/features/incidencias/application/estado_incidencias.dart';
import 'package:inventario/features/incidencias/domain/datos_incidencia.dart';
import 'package:inventario/features/incidencias/domain/filtrar_incidencias.dart';
import 'package:inventario/features/incidencias/domain/incidencia.dart';
import 'package:inventario/features/incidencias/domain/repositorio_incidencias.dart';
import 'package:inventario/features/incidencias/domain/respuesta_proveedor.dart';
import 'package:inventario/features/incidencias/domain/resultado_incidencia.dart';
import 'package:inventario/features/incidencias/domain/sacar_de_lote.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/domain/datos_producto.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/domain/resultado_guardar_producto.dart';

/// Incidents with suppliers. Registering one can take the damaged goods out
/// of the stock; the last registration can be undone.
class ControladorIncidencias extends ChangeNotifier {
  ControladorIncidencias(
    this._repositorio,
    this._existencias, {
    this._ahora = DateTime.now,
    this._movimientos,
  });

  final RepositorioIncidencias _repositorio;
  final ControladorExistencias _existencias;
  final DateTime Function() _ahora;

  /// Where goods taken out are noted for the kardex; optional in tests.
  final ControladorMovimientos? _movimientos;
  EstadoIncidencias _estado = const CargandoIncidencias();
  ({
    Incidencia incidencia,
    Producto? antes,
    Producto? despues,
    Movimiento? anotado,
  })?
  _ultima;

  EstadoIncidencias get estado => _estado;
  DateTime get hoy => _ahora();
  bool get puedeDeshacer => _ultima != null;

  /// Newest first.
  List<Incidencia> get todas => switch (_estado) {
    CargandoIncidencias() => const [],
    IncidenciasCargadas(:final incidencias) => incidencias,
  };

  List<Incidencia> de(String proveedor) => incidenciasDe(proveedor, todas);

  int abiertasDe(String proveedor) =>
      de(proveedor).where((i) => i.abierta).length;

  Future<void> cargar() async {
    _poner(await _repositorio.obtenerTodas());
  }

  Future<ResultadoIncidencia> registrar(DatosIncidencia datos) async {
    Producto? antes;
    Producto? despues;
    if (datos.sacada) {
      antes = _buscar(datos.productoId);
      final sacado = antes == null
          ? null
          : sacarDeLote(
              antes,
              marca: datos.marca,
              proveedor: datos.proveedor,
              piezas: datos.piezas,
              cantidad: datos.cantidad,
            );
      if (sacado == null) return const ExistenciaInsuficiente();
      final guardado = await _existencias.actualizarProducto(
        sacado.id,
        DatosProducto.desde(sacado),
      );
      switch (guardado) {
        case ProductoGuardado(:final producto):
          despues = producto;
        // The name is unchanged, so it cannot clash with another product.
        case NombreRepetido():
          return const ExistenciaInsuficiente();
      }
    }
    final incidencia = await _repositorio.crear(datos);
    final anotado = despues == null
        ? null
        : await _movimientos?.anotar(
            Movimiento(
              fecha: datos.fecha,
              tipo: TipoMovimiento.incidencia,
              productoId: datos.productoId,
              producto: datos.producto,
              forma: datos.forma,
              marca: datos.marca,
              proveedor: datos.proveedor,
              piezas: datos.piezas,
              cantidad: datos.cantidad,
              nota: '${datos.proveedor} · ${datos.tipo.etiqueta}',
            ),
          );
    _ultima = (
      incidencia: incidencia,
      antes: antes,
      despues: despues,
      anotado: anotado,
    );
    _poner([...todas, incidencia]);
    return IncidenciaRegistrada(incidencia);
  }

  /// Removes the last incident and puts its goods back. Refused (false)
  /// when that product changed since, to not lose the change.
  Future<bool> deshacer() async {
    final ultima = _ultima;
    if (ultima == null) return false;
    _ultima = null;
    final antes = ultima.antes;
    final despues = ultima.despues;
    if (antes != null && despues != null) {
      if (_buscar(despues.id) != despues) {
        notifyListeners();
        return false;
      }
      await _existencias.actualizarProducto(
        antes.id,
        DatosProducto.desde(antes),
      );
    }
    if (ultima.anotado case final anotado?) {
      await _movimientos?.quitar(anotado);
    }
    await _repositorio.borrar(ultima.incidencia.id);
    _poner([
      for (final i in todas)
        if (i.id != ultima.incidencia.id) i,
    ]);
    return true;
  }

  /// A null [respuesta] reopens the incident.
  Future<void> responder(
    Incidencia incidencia,
    RespuestaProveedor? respuesta,
  ) async {
    final respondida = incidencia.conRespuesta(respuesta);
    await _repositorio.actualizar(respondida);
    _poner([for (final i in todas) i.id == incidencia.id ? respondida : i]);
  }

  /// Keeps incidents linked when a supplier is renamed.
  Future<void> renombrarProveedor(String anterior, String nuevo) async {
    await _repositorio.renombrarProveedor(anterior, nuevo);
    await cargar();
  }

  void _poner(List<Incidencia> incidencias) {
    _estado = IncidenciasCargadas(
      [...incidencias]..sort((a, b) => b.fecha.compareTo(a.fecha)),
    );
    notifyListeners();
  }

  Producto? _buscar(String id) {
    for (final producto in _existencias.productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }
}
