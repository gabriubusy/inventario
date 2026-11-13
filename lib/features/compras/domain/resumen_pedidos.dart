import 'package:inventario/core/fechas.dart';
import 'package:inventario/features/compras/domain/compra.dart';

/// The figures on top of the orders screen.
class ResumenPedidos {
  const ResumenPedidos({
    required this.pendientes,
    required this.porRecibir,
    required this.masViejo,
    required this.recibidos,
    required this.conDiferencias,
    required this.diferenciaMes,
  });

  /// Days back that count as "this week" and "this month".
  static const diasSemana = 7;
  static const diasMes = 30;

  factory ResumenPedidos.de(List<Compra> compras, DateTime hoy) {
    final esperando = [for (final c in compras) if (c.estado.esperando) c];
    final semana = [
      for (final c in compras)
        if (c.recibidaEl case final cuando?)
          if (diasEntre(cuando, hoy) < diasSemana) c,
    ];
    var diferencia = 0;
    for (final compra in compras) {
      final cuando = compra.recibidaEl;
      if (cuando == null || diasEntre(cuando, hoy) >= diasMes) continue;
      diferencia += compra.diferencia;
    }
    return ResumenPedidos(
      pendientes: esperando.length,
      porRecibir: esperando.fold(0, (t, c) => t + c.porRecibir),
      masViejo: esperando.isEmpty
          ? null
          : esperando.map((c) => c.fecha).reduce((a, b) => a.isBefore(b) ? a : b),
      recibidos: semana.length,
      conDiferencias: semana.where((c) => c.lineasConDiferencia > 0).length,
      diferenciaMes: diferencia,
    );
  }

  /// Orders with goods still on the way.
  final int pendientes;

  /// Their value, in dollar hundredths.
  final int porRecibir;

  /// Date of the oldest one still waiting; null when none is.
  final DateTime? masViejo;

  /// Orders received over the last week, and how many of them differed.
  final int recibidos;
  final int conDiferencias;

  /// More (or less) than ordered over the last month, in dollar
  /// hundredths; negative when suppliers brought less.
  final int diferenciaMes;
}
