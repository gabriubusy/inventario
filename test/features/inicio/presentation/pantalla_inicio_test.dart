import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/ajustes/application/controlador_ajustes.dart';
import 'package:inventario/features/ajustes/presentation/dialogo_ajuste.dart';
import 'package:inventario/features/caja/application/controlador_caja.dart';
import 'package:inventario/features/caja/data/repositorio_cajas_en_memoria.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/conteo/application/controlador_conteo.dart';
import 'package:inventario/features/conteo/presentation/pantalla_conteo.dart';
import 'package:inventario/features/entradas/application/controlador_entradas.dart';
import 'package:inventario/features/entradas/domain/entrada.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_en_memoria.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/inicio/presentation/pantalla_inicio.dart';
import 'package:inventario/features/kardex/presentation/pantalla_kardex.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/application/controlador_lista_productos.dart';
import 'package:inventario/features/productos/application/gestor_fotos.dart';
import 'package:inventario/features/productos/data/almacen_imagenes_en_memoria.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/productos/presentation/dialogo_nuevo_producto.dart';
import 'package:inventario/features/productos/presentation/pantalla_productos.dart';
import 'package:inventario/features/productos/presentation/tarjeta_producto.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/presentation/pantalla_proveedores.dart';
import 'package:inventario/features/salidas/application/controlador_devoluciones.dart';
import 'package:inventario/features/salidas/application/controlador_salidas.dart';
import 'package:inventario/features/salidas/data/repositorio_ventas_en_memoria.dart';
import 'package:inventario/features/salidas/domain/salida.dart';
import 'package:inventario/features/salidas/presentation/dialogo_salida.dart';
import 'package:inventario/features/tasa/application/controlador_tasa.dart';
import 'package:inventario/features/tasa/data/almacen_tasa_en_memoria.dart';
import 'package:inventario/features/tasa/domain/fuente_tasa.dart';
import 'package:inventario/features/tasa/presentation/dialogo_tasa.dart';

class _FuenteFija implements FuenteTasa {
  const _FuenteFija(this._respuesta);

  final ResultadoConsultaTasa _respuesta;

  @override
  Future<ResultadoConsultaTasa> consultar() async => _respuesta;
}

void main() {
  late ControladorExistencias controlador;
  late ControladorProveedores proveedores;
  late ControladorTasa tasa;
  late ControladorEntradas entradas;
  late ControladorSalidas salidas;
  late ControladorMovimientos movimientos;
  var bloqueos = 0;
  var cambiosPin = 0;

  setUp(() async {
    tasa = ControladorTasa(AlmacenTasaEnMemoria());
    controlador = ControladorExistencias(
      RepositorioProductosEnMemoria([
        const Producto(
          id: '1',
          nombre: 'Bistec de res',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 8000,
          lotes: [LoteMarca(marca: 'Propia', cantidad: 18500)],
        ),
        const Producto(
          id: '2',
          nombre: 'Jamón de pierna',
          categoria: Categoria.embutidos,
          forma: FormaConteo.piezasYKilos,
          minimo: 5,
          lotes: [
            LoteMarca(
              marca: 'Marca F',
              piezas: 3,
              piezaAbierta: true,
              cantidad: 16400,
            ),
          ],
        ),
        const Producto(
          id: '3',
          nombre: 'Queso guayanés',
          categoria: Categoria.quesos,
          forma: FormaConteo.piezasYKilos,
          minimo: 3,
        ),
      ]),
    );
    await controlador.cargar();
    proveedores = ControladorProveedores(
      RepositorioProveedoresEnMemoria(const [
        Proveedor(id: 'v1', nombre: 'Distribuidora 1'),
      ]),
      controlador,
    );
    await proveedores.cargar();
    entradas = ControladorEntradas(controlador);
    movimientos = ControladorMovimientos(RepositorioMovimientosEnMemoria());
    salidas = ControladorSalidas(controlador, movimientos: movimientos);
    bloqueos = 0;
    cambiosPin = 0;
  });

  tearDown(() {
    controlador.dispose();
    proveedores.dispose();
  });

  Future<void> mostrar(
    WidgetTester tester, {
    Size ventana = const Size(1280, 900),
  }) async {
    await tester.binding.setSurfaceSize(ventana);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaInicio(
          controlador: controlador,
          proveedores: proveedores,
          entradas: entradas,
          salidas: salidas,
          incidencias: ControladorIncidencias(
            RepositorioIncidenciasEnMemoria(),
            controlador,
          ),
          movimientos: movimientos,
          compras: ControladorCompras(
            RepositorioComprasEnMemoria(),
            controlador,
          ),
          gastos: ControladorGastos(RepositorioGastosEnMemoria()),
          caja: ControladorCaja(
            RepositorioCajasEnMemoria(),
            RepositorioVentasEnMemoria(),
          ),
          ajustes: ControladorAjustes(controlador, movimientos: movimientos),
          conteo: ControladorConteo(controlador, movimientos: movimientos),
          devoluciones: ControladorDevoluciones(controlador, movimientos),
          listaProductos: ControladorListaProductos(controlador),
          tasa: tasa,
          fotos: GestorFotos(AlmacenImagenesEnMemoria()),
          onBloquear: () => bloqueos++,
          onCambiarPin: () => cambiosPin++,
        ),
      ),
    );
  }

  Future<void> pulsarConControl(
    WidgetTester tester,
    LogicalKeyboardKey tecla,
  ) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  Finder enTarjeta(String texto) => find.descendant(
    of: find.byType(TarjetaProducto),
    matching: find.text(texto),
  );

  testWidgets('shows pieces, the open piece and the brands of a cheese', (
    tester,
  ) async {
    await mostrar(tester);
    expect(enTarjeta('3 piezas  +1 abierta · 16,4 kg'), findsOneWidget);
    expect(enTarjeta('Marca F: 3 + 1 abierta'), findsOneWidget);
  });

  testWidgets('lists every product with its stock and alert', (tester) async {
    await mostrar(tester);
    expect(find.byType(TarjetaProducto), findsNWidgets(3));
    expect(enTarjeta('18,5 kg'), findsOneWidget);
    expect(enTarjeta('Stock bajo'), findsOneWidget);
    expect(enTarjeta('Agotado'), findsOneWidget);
  });

  testWidgets('search narrows the list ignoring accents', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'jamon');
    await tester.pump();
    expect(find.byType(TarjetaProducto), findsOneWidget);
    expect(enTarjeta('Jamón de pierna'), findsOneWidget);
  });

  testWidgets('Esc clears the search', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'jamon');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byType(TarjetaProducto), findsNWidgets(3));
  });

  testWidgets('says so when nothing matches', (tester) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'pescado');
    await tester.pump();
    expect(find.text('No hay productos que coincidan'), findsOneWidget);
  });

  testWidgets('a category chip filters the list', (tester) async {
    await mostrar(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Quesos'));
    await tester.pump();
    expect(find.byType(TarjetaProducto), findsOneWidget);
    expect(enTarjeta('Queso guayanés'), findsOneWidget);
  });

  testWidgets('Ctrl+K moves the focus to the search box', (tester) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyK);
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.focusNode?.hasFocus, isTrue);
  });

  testWidgets('a sale shows up in the latest sales and the day total', (
    tester,
  ) async {
    await mostrar(tester);
    expect(find.text('Aún no hay ventas hoy. Registra una con F1.'), findsOne);
    await tester.runAsync(
      () =>
          salidas.registrar('1', const Salida(marca: 'Propia', cantidad: 2000)),
    );
    await tester.pump();
    expect(find.text('Bistec de res'), findsWidgets);
    expect(find.text('Propia · 2 kg'), findsOneWidget);
    expect(find.text('2 kg'), findsOneWidget);
  });

  testWidgets('sold-out products are listed to restock', (tester) async {
    await mostrar(tester);
    final reponer = find.ancestor(
      of: find.text('Hay que reponer'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: reponer.last, matching: find.text('Queso guayanés')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: reponer.last, matching: find.text('Bistec de res')),
      findsNothing,
    );
  });

  testWidgets('F1 opens the sale window', (tester) async {
    await tester.runAsync(() => tasa.guardar(88730));
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoSalida), findsOneWidget);
  });

  testWidgets('entering without today\'s rate asks for it once', (
    tester,
  ) async {
    await tester.runAsync(tasa.cargar);
    await mostrar(tester);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoTasa), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoTasa), findsNothing);
  });

  testWidgets('F1 without today\'s rate asks for it before selling', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoTasa), findsOneWidget);
    expect(find.byType(DialogoSalida), findsNothing);
  });

  testWidgets('F3 opens the merma window', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAjuste), findsOneWidget);
  });

  testWidgets('F9 opens the physical count and Esc comes back', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f9);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaConteo), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaConteo), findsNothing);
  });

  testWidgets('F8 opens the kardex on the product search', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f8);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaKardex), findsOneWidget);
  });

  testWidgets('Ctrl+Z undoes the last sale, not an older entry', (
    tester,
  ) async {
    await mostrar(tester);
    final jamon = controlador.productos.firstWhere((p) => p.id == '2');
    await entradas.registrar(
      '2',
      const Entrada(marca: 'Marca F', piezas: 1, cantidad: 4000),
    );
    await salidas.registrar('1', const Salida(marca: 'Propia', cantidad: 500));
    await pulsarConControl(tester, LogicalKeyboardKey.keyZ);
    await tester.pumpAndSettle();
    expect(find.text('Salida deshecha'), findsOneWidget);
    expect(
      controlador.productos.firstWhere((p) => p.id == '1').cantidad,
      18500,
    );
    expect(
      controlador.productos.firstWhere((p) => p.id == '2').piezas,
      jamon.piezas + 1,
    );
  });

  testWidgets('a narrow window folds the header links into a menu', (
    tester,
  ) async {
    await mostrar(tester, ventana: const Size(920, 760));
    expect(find.text('Cambiar PIN'), findsNothing);
    await tester.tap(find.text('Menú'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cambiar PIN'));
    await tester.pumpAndSettle();
    expect(cambiosPin, 1);
  });

  testWidgets('a wide window shows the header links side by side', (
    tester,
  ) async {
    await mostrar(tester, ventana: const Size(2400, 900));
    expect(find.text('Menú'), findsNothing);
    expect(find.text('Cambiar PIN'), findsOneWidget);
  });

  testWidgets('Ctrl+L locks the session', (tester) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyL);
    expect(bloqueos, 1);
  });

  testWidgets('Ctrl+Shift+L changes the PIN instead of locking', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    expect(cambiosPin, 1);
    expect(bloqueos, 0);
  });

  testWidgets('F7 opens today\'s sales to cancel one', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f7);
    await tester.pumpAndSettle();
    expect(find.text('Ventas de hoy'), findsOneWidget);
  });

  testWidgets('F5 opens the suppliers and Esc comes back', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProveedores), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProveedores), findsNothing);
    expect(find.text('Existencias'), findsOneWidget);
  });

  testWidgets("the header shows today's BCV rate and how much it moved", (
    tester,
  ) async {
    tasa = ControladorTasa(
      AlmacenTasaEnMemoria(),
      fuente: const _FuenteFija(TasaObtenida(88623, anterior: 88475)),
    );
    await tasa.actualizarDesdeInternet();
    await mostrar(tester);
    expect(find.text('BCV hoy'), findsOneWidget);
    expect(find.text('1 \$ = 886,23 Bs'), findsOneWidget);
    expect(find.text('0,17 %'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('without internet the rate can be typed in with Ctrl+T', (
    tester,
  ) async {
    tasa = ControladorTasa(
      AlmacenTasaEnMemoria(),
      fuente: const _FuenteFija(TasaNoDisponible()),
    );
    await tasa.actualizarDesdeInternet();
    await mostrar(tester);
    expect(find.textContaining('¿sin internet?'), findsOneWidget);

    await pulsarConControl(tester, LogicalKeyboardKey.keyT);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Bolívares por 1 dólar'),
      '890',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Tasa de hoy'), findsOneWidget);
    expect(find.text('1 \$ = 890,00 Bs'), findsOneWidget);
    expect(find.textContaining('¿sin internet?'), findsNothing);
  });

  testWidgets('F4 opens the products and Esc comes back', (tester) async {
    await mostrar(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProductos), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaProductos), findsNothing);
  });

  testWidgets('Ctrl+N opens the new product window', (tester) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
  });

  testWidgets('home shortcuts stay quiet while the window is open', (
    tester,
  ) async {
    await mostrar(tester);
    await pulsarConControl(tester, LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    await pulsarConControl(tester, LogicalKeyboardKey.keyN);
    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoNuevoProducto), findsOneWidget);
    expect(find.text('Próximamente: Registrar merma'), findsNothing);
  });

  testWidgets('home shortcuts work while typing in the search box', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.enterText(find.byType(TextField), 'jam');
    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAjuste), findsOneWidget);
  });

  testWidgets('a product created from home appears in the grid', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.tap(find.text('Nuevo producto'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Queso de año',
    );
    final crear = find.widgetWithText(FilledButton, 'Crear');
    await tester.ensureVisible(crear);
    await tester.pumpAndSettle();
    await tester.tap(crear);
    await tester.pumpAndSettle();
    // The grid builds lazily under the day panel, so scroll down to it.
    expect(
      controlador.productos.map((p) => p.nombre),
      contains('Queso de año'),
    );
    await tester.dragUntilVisible(
      enTarjeta('Queso de año'),
      find.byType(CustomScrollView),
      const Offset(0, -200),
    );
    expect(enTarjeta('Queso de año'), findsOneWidget);
  });
}
