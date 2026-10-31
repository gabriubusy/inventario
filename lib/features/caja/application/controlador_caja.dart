import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/caja/domain/movimiento_caja.dart';
import 'package:inventario/features/caja/domain/movimientos_caja.dart';
import 'package:inventario/features/caja/domain/repositorio_cajas.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/salidas/domain/repositorio_ventas.dart';
import 'package:inventario/features/salidas/domain/venta.dart';

/// The till (F11): opening cash, every money movement while open and the
/// closing count by way of paying.
class ControladorCaja extends ChangeNotifier {
  ControladorCaja(
    this._repositorio,
    this._ventas, {
    this._movimientos,
    this._compras,
    this._gastos,
    this._devolucionesProveedor,
    this._tasaDeHoy,
    this._ahora = DateTime.now,
  });

  final RepositorioCajas _repositorio;
  final RepositorioVentas _ventas;
  final ControladorMovimientos? _movimientos;
  final ControladorCompras? _compras;
  final ControladorGastos? _gastos;
  final ControladorDevolucionesProveedor? _devolucionesProveedor;
  final int? Function()? _tasaDeHoy;
  final DateTime Function() _ahora;
  List<Caja> _cajas = const [];
  List<Venta> _todasLasVentas = const [];

  int? get tasaDeHoy => _tasaDeHoy?.call();
  DateTime get hoy => _ahora();

  /// Every sale ever made; reports use it too.
  List<Venta> get ventas => _todasLasVentas;

  /// The till open now; null when it was closed or never opened.
  Caja? get abierta {
    for (final caja in _cajas) {
      if (caja.estaAbierta) return caja;
    }
    return null;
  }

  /// Nothing opened today yet: the home screen reminds to open it. Once
  /// today's till is closed it stops asking.
  bool get faltaAbrirHoy {
    final hoy = _ahora();
    return !_cajas.any(
      (c) =>
          c.estaAbierta ||
          c.abierta.year == hoy.year &&
              c.abierta.month == hoy.month &&
              c.abierta.day == hoy.day,
    );
  }

  /// The last closed till, to show how it ended.
  Caja? get ultimaCerrada {
    Caja? ultima;
    for (final caja in _cajas) {
      if (!caja.estaAbierta &&
          (ultima == null || caja.cerrada!.isAfter(ultima.cerrada!))) {
        ultima = caja;
      }
    }
    return ultima;
  }

  List<MovimientoCaja> movimientosDe(Caja caja) => movimientosDeCaja(
    caja: caja,
    ventas: _todasLasVentas,
    lineas: _movimientos?.todos ?? const [],
    compras: _compras?.compras ?? const [],
    pagos: _compras?.pagos ?? const [],
    gastos: _gastos?.todos ?? const [],
    devolucionesProveedor: _devolucionesProveedor?.todas ?? const [],
  );

  Map<MedioPago, int> saldosDe(Caja caja) => saldosDeCaja(movimientosDe(caja));

  /// Reads tills and sales again; called when the screen opens.
  Future<void> cargar() async {
    _cajas = await _repositorio.obtenerTodas();
    _todasLasVentas = await _ventas.obtenerTodas();
    notifyListeners();
  }

  /// Returns the till already open instead of opening a second one, even
  /// when Enter is pressed twice while the first is being saved.
  Future<Caja> abrir({
    required int fondoDolares,
    required int fondoBolivares,
  }) async {
    if (abierta case final ya?) return ya;
    final enCurso = _abriendo;
    if (enCurso != null) return enCurso;
    final abriendo = _repositorio.abrir(
      Caja(
        abierta: _ahora(),
        fondoDolares: fondoDolares,
        fondoBolivares: fondoBolivares,
      ),
    );
    _abriendo = abriendo;
    try {
      final nueva = await abriendo;
      _cajas = [..._cajas, nueva];
      notifyListeners();
      return nueva;
    } finally {
      _abriendo = null;
    }
  }

  Future<Caja>? _abriendo;

  /// Closes the open till with what was counted of each way of paying.
  Future<Caja?> cerrar(Map<MedioPago, int> contado, {String nota = ''}) async {
    final caja = abierta;
    if (caja == null) return null;
    final cerrada = caja.cerradaCon(
      fecha: _ahora(),
      contado: contado,
      nota: nota,
    );
    await _repositorio.cerrar(cerrada);
    _antesDelCierre = caja;
    _cajas = [for (final c in _cajas) c.id == caja.id ? cerrada : c];
    notifyListeners();
    return cerrada;
  }

  Caja? _antesDelCierre;

  /// Opens again the till just closed (a wrong count), unless another one
  /// was opened since.
  Future<bool> deshacerCierre() async {
    final antes = _antesDelCierre;
    _antesDelCierre = null;
    if (antes == null || abierta != null) return false;
    // Saving the open version writes its closing fields back to empty.
    await _repositorio.cerrar(antes);
    _cajas = [for (final c in _cajas) c.id == antes.id ? antes : c];
    notifyListeners();
    return true;
  }
}
