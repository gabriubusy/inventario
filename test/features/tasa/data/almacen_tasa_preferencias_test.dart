import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_preferencias.dart';
import 'package:inventario/features/tasa/domain/origen_tasa.dart';
import 'package:inventario/features/tasa/domain/tasa_cambio.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('reads nothing before a rate is saved', () async {
    expect(await AlmacenTasaPreferencias().leer(), isNull);
  });

  test('a new instance reads the saved rate, its day and origin', () async {
    final tasa = TasaCambio(
      bolivaresPorDolar: 88623,
      fecha: DateTime(2026, 10, 26),
      origen: OrigenTasa.bcv,
      anterior: 88475,
    );
    await AlmacenTasaPreferencias().guardar(tasa);
    expect(await AlmacenTasaPreferencias().leer(), tasa);
  });
}
