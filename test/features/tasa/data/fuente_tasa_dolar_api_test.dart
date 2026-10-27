import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inventario/features/tasa/data/fuente_tasa_dolar_api.dart';
import 'package:inventario/features/tasa/domain/fuente_tasa.dart';

void main() {
  // Monday: the BCV already published Tuesday's rate.
  final lunes = DateTime(2026, 10, 26, 9);
  const historico = '''
[
  {"fuente":"oficial","promedio":884.7496,"fecha":"2026-10-22"},
  {"fuente":"oficial","promedio":887.302,"fecha":"2026-10-27"},
  {"fuente":"oficial","promedio":886.2271,"fecha":"2026-10-23"}
]''';

  Future<ResultadoConsultaTasa> consultar(MockClientHandler responder) =>
      FuenteTasaDolarApi(
        cliente: MockClient(responder),
        ahora: () => lunes,
      ).consultar();

  test("takes today's rate and the previous one from the history", () async {
    Uri? pedida;
    final resultado = await consultar((peticion) async {
      pedida = peticion.url;
      return http.Response(historico, 200);
    });
    expect(
      pedida.toString(),
      'https://ve.dolarapi.com/v1/historicos/dolares/oficial',
    );
    final obtenida = resultado as TasaObtenida;
    expect(obtenida.bolivaresPorDolar, 88623);
    expect(obtenida.anterior, 88475);
  });

  test('ignores a rate published in advance for a later day', () async {
    final resultado = await consultar(
      (_) async => http.Response(historico, 200),
    );
    expect((resultado as TasaObtenida).bolivaresPorDolar, isNot(88730));
  });

  test('has no previous rate when the history has only one day', () async {
    final resultado = await consultar(
      (_) async =>
          http.Response('[{"promedio":886.2271,"fecha":"2026-10-23"}]', 200),
    );
    expect((resultado as TasaObtenida).anterior, isNull);
  });

  test('is unavailable when the service answers with an error', () async {
    final resultado = await consultar((_) async => http.Response('caído', 503));
    expect(resultado, isA<TasaNoDisponible>());
  });

  test('is unavailable when the answer is not the expected JSON', () async {
    for (final cuerpo in [
      '<html>',
      '{"promedio":886}',
      '[]',
      '[{"promedio":"x","fecha":"2026-10-23"}]',
      '[{"promedio":886,"fecha":"2026-10-30"}]',
    ]) {
      final resultado = await consultar(
        (_) async => http.Response(cuerpo, 200),
      );
      expect(resultado, isA<TasaNoDisponible>(), reason: cuerpo);
    }
  });

  test('is unavailable without internet', () async {
    final resultado = await consultar(
      (_) async => throw http.ClientException('sin conexión'),
    );
    expect(resultado, isA<TasaNoDisponible>());
  });
}
