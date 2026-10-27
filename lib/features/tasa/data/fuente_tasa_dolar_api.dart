import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventario/features/tasa/domain/fuente_tasa.dart';

typedef _Publicada = ({DateTime fecha, int valor});

/// Official BCV rates from DolarApi (free, no key, allows browser calls).
/// The history gives today's rate and the previous one in a single call.
class FuenteTasaDolarApi implements FuenteTasa {
  FuenteTasaDolarApi({http.Client? cliente, DateTime Function()? ahora})
    : _cliente = cliente ?? http.Client(),
      _ahora = ahora ?? DateTime.now;

  static final _direccion = Uri.parse(
    'https://ve.dolarapi.com/v1/historicos/dolares/oficial',
  );
  static const _espera = Duration(seconds: 15);

  final http.Client _cliente;
  final DateTime Function() _ahora;

  @override
  Future<ResultadoConsultaTasa> consultar() async {
    final http.Response respuesta;
    try {
      respuesta = await _cliente.get(_direccion).timeout(_espera);
    } on http.ClientException {
      return const TasaNoDisponible();
    } on TimeoutException {
      return const TasaNoDisponible();
    }
    if (respuesta.statusCode != 200) return const TasaNoDisponible();
    final Object? datos;
    try {
      datos = jsonDecode(respuesta.body);
    } on FormatException {
      return const TasaNoDisponible();
    }
    return _elegir(_publicadas(datos));
  }

  /// The BCV publishes the next business day's rate in advance, so today's
  /// is the latest one dated today or earlier.
  ResultadoConsultaTasa _elegir(List<_Publicada> publicadas) {
    final hoy = _ahora();
    final finDeHoy = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final vigentes = [
      for (final p in publicadas)
        if (p.fecha.isBefore(finDeHoy)) p,
    ];
    if (vigentes.isEmpty) return const TasaNoDisponible();
    return TasaObtenida(
      vigentes.last.valor,
      anterior: vigentes.length > 1
          ? vigentes[vigentes.length - 2].valor
          : null,
    );
  }

  /// Valid entries, oldest first. Each average becomes hundredths here.
  List<_Publicada> _publicadas(Object? datos) {
    if (datos is! List<Object?>) return const [];
    return [
      for (final dato in datos)
        if (dato
            case {'promedio': final num promedio, 'fecha': final String texto}
            when promedio > 0)
          if (DateTime.tryParse(texto) case final fecha?)
            (fecha: fecha, valor: (promedio * 100).round()),
    ]..sort((a, b) => a.fecha.compareTo(b.fecha));
  }
}
