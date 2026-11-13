import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/incidencias/application/controlador_incidencias.dart';
import 'package:inventario/features/incidencias/data/repositorio_incidencias_en_memoria.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/categoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/productos/domain/lote_marca.dart';
import 'package:inventario/features/productos/domain/producto.dart';
import 'package:inventario/features/proveedores/application/controlador_proveedores.dart';
import 'package:inventario/features/proveedores/data/repositorio_proveedores_en_memoria.dart';
import 'package:inventario/features/proveedores/domain/proveedor.dart';
import 'package:inventario/features/proveedores/presentation/pantalla_proveedores.dart';

void main() {
  late ControladorExistencias existencias;
  late ControladorProveedores controlador;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const [
        Producto(
          id: 'q',
          nombre: 'Queso blanco duro',
          categoria: Categoria.quesos,
          forma: FormaConteo.porKilo,
          minimo: 5000,
          lotes: [
            LoteMarca(
              marca: 'Marca agotada',
              proveedor: 'Distribuidora 1',
              cantidad: 0,
            ),
            LoteMarca(
              marca: 'Marca con stock',
              proveedor: 'Distribuidora 1',
              cantidad: 4200,
            ),
          ],
        ),
      ]),
    );
    await existencias.cargar();
    controlador = ControladorProveedores(
      RepositorioProveedoresEnMemoria(const [
        Proveedor(id: 'v1', nombre: 'Distribuidora 1'),
      ]),
      existencias,
    );
    await controlador.cargar();
  });

  tearDown(() {
    controlador.dispose();
    existencias.dispose();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaProveedores(
          controlador: controlador,
          existencias: existencias,
          compras: ControladorCompras(
            RepositorioComprasEnMemoria(),
            existencias,
          ),
          incidencias: ControladorIncidencias(
            RepositorioIncidenciasEnMemoria(),
            existencias,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder cruz(String marca) =>
      find.byTooltip('Quitar $marca de los productos de este proveedor');

  List<String> marcasDelProducto() => [
    for (final lote in existencias.productos.single.lotes) lote.marca,
  ];

  testWidgets('the cross takes a brand with no stock off its products', (
    tester,
  ) async {
    await mostrar(tester);
    await tester.tap(cruz('Marca agotada'));
    await tester.pumpAndSettle();
    expect(marcasDelProducto(), ['Marca con stock']);
    expect(find.text('Marca agotada fuera de 1 producto'), findsOneWidget);
  });

  testWidgets('Deshacer brings the brand back', (tester) async {
    await mostrar(tester);
    await tester.tap(cruz('Marca agotada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(marcasDelProducto(), ['Marca agotada', 'Marca con stock']);
  });

  testWidgets('a brand with stock cannot be taken off', (tester) async {
    await mostrar(tester);
    expect(cruz('Marca con stock'), findsNothing);
    final boton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip(
          'Queda stock de Marca con stock: sale con ventas, mermas o '
          'Conteo (F9)',
        ),
        matching: find.byType(IconButton),
      ),
    );
    expect(boton.onPressed, isNull);
  });
}
