import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/core/medio_pago.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/compras/domain/compra.dart';
import 'package:inventario/features/compras/domain/linea_compra.dart';
import 'package:inventario/features/devoluciones_proveedor/application/controlador_devoluciones_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/data/repositorio_devoluciones_proveedor_en_memoria.dart';
import 'package:inventario/features/devoluciones_proveedor/domain/compensacion.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/dialogo_devolucion_proveedor.dart';
import 'package:inventario/features/devoluciones_proveedor/presentation/pantalla_devoluciones_proveedor.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';

void main() {
  const proveedor = 'Frigorífico 1';
  late ControladorExistencias existencias;
  late ControladorCompras compras;
  late ControladorDevolucionesProveedor devoluciones;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'm',
          nombre: 'Carne molida',
          categoria: Categoria.carnes,
          forma: FormaConteo.porKilo,
          minimo: 0,
          lotes: [
            LoteMarca(
              marca: 'Propia',
              proveedor: proveedor,
              cantidad: 10000,
              costo: 450,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    compras = ControladorCompras(
      RepositorioComprasEnMemoria(
        compras: [
          Compra(
            id: 'c1',
            fecha: DateTime(2026, 10, 22),
            proveedor: proveedor,
            factura: '1187',
            lineas: const [
              LineaCompra(
                productoId: 'm',
                producto: 'Carne molida',
                forma: FormaConteo.porKilo,
                marca: 'Propia',
                cantidad: 10000,
                costo: 450,
              ),
            ],
            vence: DateTime(2026, 11, 6),
          ),
        ],
      ),
      existencias,
      tasaDeHoy: () => 88623,
    );
    await compras.cargar();
    devoluciones = ControladorDevolucionesProveedor(
      RepositorioDevolucionesProveedorEnMemoria(),
      existencias,
      compras,
    );
  });

  tearDown(() {
    devoluciones.dispose();
    compras.dispose();
    existencias.dispose();
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => unawaited(
                mostrarDialogoDevolucionProveedor(
                  context,
                  devoluciones: devoluciones,
                  existencias: existencias,
                  proveedorInicial: proveedor,
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  Future<void> agregarMolida(WidgetTester tester, String kilos) async {
    await tester.enterText(campo('Producto'), 'molida');
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Carne molida'));
    await tester.pumpAndSettle();
    await tester.enterText(campo('Cantidad'), kilos);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Añadir'));
    await tester.pumpAndSettle();
  }

  Future<void> atajo(
    WidgetTester tester,
    LogicalKeyboardKey modificador,
    LogicalKeyboardKey tecla,
  ) async {
    await tester.sendKeyDownEvent(modificador);
    await tester.sendKeyEvent(tecla);
    await tester.sendKeyUpEvent(modificador);
    await tester.pumpAndSettle();
  }

  testWidgets('Ctrl+S discounts the oldest invoice owed', (tester) async {
    await abrir(tester);
    await agregarMolida(tester, '2');
    expect(find.text(r'Debe $ 45,00 → $ 36,00'), findsOneWidget);
    await atajo(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyS,
    );
    expect(find.byType(DialogoDevolucionProveedor), findsNothing);
    expect(compras.cuentas.single.debe, 3600);
    expect(existencias.productos.single.lotes.single.cantidad, 8000);
    expect(find.textContaining('Devolución registrada'), findsOneWidget);
  });

  testWidgets('Alt+W and Alt+G give money back by Zelle', (tester) async {
    await abrir(tester);
    await agregarMolida(tester, '1');
    await atajo(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyW);
    await atajo(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyG);
    await atajo(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyS,
    );
    final devolucion = devoluciones.todas.single;
    expect(devolucion.compensacion, Compensacion.dinero);
    expect(devolucion.medio, MedioPago.zelle);
    expect(devolucion.entregado, 450);
    expect(compras.cuentas.single.devuelto, 0);
  });

  testWidgets('more than the invoice owes is told, not saved', (tester) async {
    await abrir(tester);
    await agregarMolida(tester, '10');
    await compras.pagar(
      compras.cuentas.single,
      medio: MedioPago.zelle,
      entregado: 1000,
    );
    await tester.pumpAndSettle();
    await atajo(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyS,
    );
    expect(find.textContaining('La factura solo debe'), findsOneWidget);
    expect(devoluciones.todas, isEmpty);
  });

  testWidgets('in the list Alt+R marks the goods as brought', (tester) async {
    await abrir(tester);
    await agregarMolida(tester, '1');
    await atajo(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyE);
    await atajo(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyS,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaDevolucionesProveedor(
          devoluciones: devoluciones,
          existencias: existencias,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Repone · pendiente'), findsOneWidget);
    await atajo(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.keyR);
    expect(find.text('Repone · pendiente'), findsNothing);
    expect(devoluciones.todas.single.pendiente, isFalse);
  });
}
