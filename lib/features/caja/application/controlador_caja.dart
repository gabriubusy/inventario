import 'package:flutter/foundation.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/caja/domain/caja.dart';
import 'package:inventario/features/caja/domain/movimiento_caja.dart';
import 'package:inventario/features/caja/domain/movimientos_caja.dart';
import 'package:inventario/features/caja/domain/repositorio_cajas.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
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
    this._tasaDeHoy,
    this._ahora = DateTime.now,
  });

  final RepositorioCajas _repositorio;
  final RepositorioVentas _ventas;
  final ControladorMovimientos? _movimientos;
  final ControladorCompras? _compras;
  final ControladorGastos? _gastos;
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
  );

  Map<MedioPago, int> saldosDe(Caja caja) => saldosDeCaja(movimientosDe(caja));

  /// Reads tills and sales again; called when the screen opens.
  Future<void> cargar() async {
    _cajas = await _repositorio.obtenerTodas();
    _todasLasVentas = await _ventas.obtenerTodas();
    notifyListeners();
  }

  Future<Caja> abrir({
    required int fondoDolares,
    required int fondoBolivares,
  }) async {
    final abierta = await _repositorio.abrir(
      Caja(
        abierta: _ahora(),
        fondoDolares: fondoDolares,
        fondoBolivares: fondoBolivares,
      ),
    );
    _cajas = [..._cajas, abierta];
    notifyListeners();
    return abierta;
  }

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
    _cajas = [for (final c in _cajas) c.id == caja.id ? cerrada : c];
    notifyListeners();
    return cerrada;
  }
}
