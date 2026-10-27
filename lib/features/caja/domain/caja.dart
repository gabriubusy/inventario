import 'package:inventario/core/medio_pago.dart';

/// One working day of the till: the cash it started with and, once
/// closed, what was counted of each way of paying.
class Caja {
  const Caja({
    this.id = '',
    required this.abierta,
    this.fondoDolares = 0,
    this.fondoBolivares = 0,
    this.cerrada,
    this.contado = const {},
    this.nota = '',
  });

  /// Empty until the repository stores it.
  final String id;
  final DateTime abierta;

  /// Cash in the drawer when opening, in hundredths of each currency.
  final int fondoDolares;
  final int fondoBolivares;

  /// Null while it is open.
  final DateTime? cerrada;

  /// What was counted when closing, in hundredths of each medio's currency.
  final Map<MedioPago, int> contado;
  final String nota;

  bool get estaAbierta => cerrada == null;

  /// The opening cash by way of paying.
  Map<MedioPago, int> get fondo => {
    if (fondoDolares != 0) MedioPago.efectivoDolares: fondoDolares,
    if (fondoBolivares != 0) MedioPago.efectivoBolivares: fondoBolivares,
  };

  /// Whether [fecha] falls while this till was open.
  bool incluye(DateTime fecha) {
    final cerrada = this.cerrada;
    return !fecha.isBefore(abierta) &&
        (cerrada == null || !fecha.isAfter(cerrada));
  }

  Caja conId(String id) => _copia(id: id);

  Caja cerradaCon({
    required DateTime fecha,
    required Map<MedioPago, int> contado,
    String nota = '',
  }) => _copia(cerrada: fecha, contado: contado, nota: nota);

  Caja _copia({
    String? id,
    DateTime? cerrada,
    Map<MedioPago, int>? contado,
    String? nota,
  }) => Caja(
    id: id ?? this.id,
    abierta: abierta,
    fondoDolares: fondoDolares,
    fondoBolivares: fondoBolivares,
    cerrada: cerrada ?? this.cerrada,
    contado: contado ?? this.contado,
    nota: nota ?? this.nota,
  );

  @override
  bool operator ==(Object other) =>
      other is Caja &&
      other.id == id &&
      other.abierta == abierta &&
      other.fondoDolares == fondoDolares &&
      other.fondoBolivares == fondoBolivares &&
      other.cerrada == cerrada &&
      _mismosMontos(other.contado, contado) &&
      other.nota == nota;

  @override
  int get hashCode => Object.hash(
    id,
    abierta,
    fondoDolares,
    fondoBolivares,
    cerrada,
    Object.hashAllUnordered(contado.entries.map((e) => (e.key, e.value))),
    nota,
  );

  static bool _mismosMontos(Map<MedioPago, int> a, Map<MedioPago, int> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}
