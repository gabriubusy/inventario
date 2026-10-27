import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/core/numeros.dart';
import 'package:inventario/features/gastos/domain/categoria_gasto.dart';

/// Money out (or in) of the business that is not a sale or a purchase:
/// ice, wages, a loan.
class Gasto {
  const Gasto({
    this.id = '',
    required this.fecha,
    required this.categoria,
    required this.medio,
    required this.monto,
    this.tasa,
    this.nota = '',
  });

  /// Empty until the repository stores it.
  final String id;
  final DateTime fecha;
  final CategoriaGasto categoria;
  final MedioPago medio;

  /// Hundredths of the medio's currency, always positive.
  final int monto;

  /// Bs per dollar (hundredths) that day, to report it in dollars.
  final int? tasa;
  final String nota;

  bool get esIngreso => categoria.esIngreso;

  /// Dollar hundredths; null for bolívares without a rate.
  int? get enDolares => switch (medio.moneda) {
    Moneda.dolares => monto,
    Moneda.bolivares =>
      tasa == null || tasa! <= 0
          ? null
          : dividirRedondeando(monto * 100, tasa!),
  };

  Gasto conId(String id) => Gasto(
    id: id,
    fecha: fecha,
    categoria: categoria,
    medio: medio,
    monto: monto,
    tasa: tasa,
    nota: nota,
  );

  @override
  bool operator ==(Object other) =>
      other is Gasto &&
      other.id == id &&
      other.fecha == fecha &&
      other.categoria == categoria &&
      other.medio == medio &&
      other.monto == monto &&
      other.tasa == tasa &&
      other.nota == nota;

  @override
  int get hashCode =>
      Object.hash(id, fecha, categoria, medio, monto, tasa, nota);
}
