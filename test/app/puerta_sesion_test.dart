import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/app.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/autenticacion/application/controlador_sesion.dart';
import 'package:inventario/features/autenticacion/data/almacen_sesion_en_memoria.dart';
import 'package:inventario/features/autenticacion/data/repositorio_autenticacion_en_memoria.dart';
import 'package:inventario/features/autenticacion/domain/pin.dart';
import 'package:inventario/features/autenticacion/domain/usuario.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';

void main() {
  late ControladorSesion sesion;
  late ControladorExistencias existencias;
  late ControladorProveedores proveedores;

  setUp(() async {
    sesion = ControladorSesion(
      RepositorioAutenticacionEnMemoria((
        usuario: const Usuario(id: '1', nombre: 'Ana'),
        pin: Pin.tryParse('1234')!,
      )),
      AlmacenSesionEnMemoria(),
    );
    existencias = ControladorExistencias(RepositorioProductosEnMemoria([]));
    await existencias.cargar();
    proveedores = ControladorProveedores(
      RepositorioProveedoresEnMemoria([]),
      existencias,
    );
  });

  tearDown(() {
    sesion.dispose();
    existencias.dispose();
    proveedores.dispose();
  });

  Future<void> entrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      InventarioApp(
        controladorSesion: sesion,
        controladorExistencias: existencias,
        controladorProveedores: proveedores,
        controladorEntradas: ControladorEntradas(existencias),
        controladorSalidas: ControladorSalidas(existencias),
        controladorIncidencias: ControladorIncidencias(
          RepositorioIncidenciasEnMemoria(),
          existencias,
        ),
        controladorMovimientos: ControladorMovimientos(
          RepositorioMovimientosEnMemoria(),
        ),
        controladorAjustes: ControladorAjustes(existencias),
        controladorConteo: ControladorConteo(existencias),
        controladorDevoluciones: ControladorDevoluciones(
          existencias,
          ControladorMovimientos(RepositorioMovimientosEnMemoria()),
        ),
        controladorListaProductos: ControladorListaProductos(existencias),
        controladorTasa: ControladorTasa(AlmacenTasaEnMemoria()),
        gestorFotos: GestorFotos(AlmacenImagenesEnMemoria()),
      ),
    );
    for (final digito in ['1', '2', '3', '4']) {
      await tester.tap(find.widgetWithText(OutlinedButton, digito));
    }
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the home screen after entering the PIN', (tester) async {
    await entrar(tester);
    expect(find.text('Existencias'), findsOneWidget);
  });

  testWidgets('locking goes back to the PIN screen', (tester) async {
    await entrar(tester);
    // At 1280 px the header links live in its menu.
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloquear'));
    await tester.pumpAndSettle();
    expect(find.text('Introduce tu PIN'), findsOneWidget);
  });

  testWidgets('Ctrl+L locks from the keyboard', (tester) async {
    await entrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.text('Introduce tu PIN'), findsOneWidget);
  });
}
