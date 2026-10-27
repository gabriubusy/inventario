import 'package:inventario/features/compras/domain/cuenta_por_pagar.dart';

/// The figures on top of the payables screen.
class ResumenCuentas {
  const ResumenCuentas({
    required this.debe,
    required this.vencido,
    required this.vencidas,
    required this.porVencer,
    required this.porVencerCuantas,
  });

  factory ResumenCuentas.de(List<CuentaPorPagar> cuentas, DateTime hoy) {
    int suma(Iterable<CuentaPorPagar> c) => c.fold(0, (t, x) => t + x.debe);
    final vencidas = cuentas.where(
      (c) => c.estado(hoy) == EstadoCuenta.vencida,
    );
    final pronto = cuentas.where(
      (c) => c.estado(hoy) == EstadoCuenta.porVencer,
    );
    return ResumenCuentas(
      debe: suma(cuentas.where((c) => c.debe > 0)),
      vencido: suma(vencidas),
      vencidas: vencidas.length,
      porVencer: suma(pronto),
      porVencerCuantas: pronto.length,
    );
  }

  /// All in dollar hundredths.
  final int debe;
  final int vencido;
  final int vencidas;
  final int porVencer;
  final int porVencerCuantas;

  @override
  bool operator ==(Object other) =>
      other is ResumenCuentas &&
      other.debe == debe &&
      other.vencido == vencido &&
      other.vencidas == vencidas &&
      other.porVencer == porVencer &&
      other.porVencerCuantas == porVencerCuantas;

  @override
  int get hashCode =>
      Object.hash(debe, vencido, vencidas, porVencer, porVencerCuantas);
}
