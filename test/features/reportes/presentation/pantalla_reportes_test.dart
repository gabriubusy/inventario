import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario/app/tema.dart';
import 'package:inventario/features/compras/application/controlador_compras.dart';
import 'package:inventario/features/compras/data/repositorio_compras_en_memoria.dart';
import 'package:inventario/features/gastos/application/controlador_gastos.dart';
import 'package:inventario/features/gastos/data/repositorio_gastos_en_memoria.dart';
import 'package:inventario/features/movimientos/application/controlador_movimientos.dart';
import 'package:inventario/features/movimientos/data/repositorio_movimientos_en_memoria.dart';
import 'package:inventario/features/movimientos/domain/movimiento.dart';
import 'package:inventario/features/movimientos/domain/tipo_movimiento.dart';
import 'package:inventario/features/productos/application/controlador_existencias.dart';
import 'package:inventario/features/productos/data/repositorio_productos_en_memoria.dart';
import 'package:inventario/features/productos/domain/forma_conteo.dart';
import 'package:inventario/features/reportes/domain/exportador_reportes.dart';
import 'package:inventario/features/reportes/domain/reporte.dart';
import 'package:inventario/features/reportes/presentation/pantalla_reportes.dart';

class _ExportadorFalso implements ExportadorReportes {
  final exportados = <String>[];

  @override
  Future<bool> excel(Reporte reporte, {required String nombre}) async {
    exportados.add('excel ${reporte.titulo}');
    return true;
  }

  @override
  Future<void> pdf(Reporte reporte, {required String subtitulo}) async =>
      exportados.add('pdf ${reporte.titulo}');
}

void main() {
  final hoy = DateTime(2026, 10, 27, 12);
  late ControladorExistencias existencias;
  late ControladorMovimientos movimientos;
  late ControladorCompras compras;
  late ControladorGastos gastos;
  late _ExportadorFalso exportador;

  setUp(() async {
    existencias = ControladorExistencias(
      RepositorioProductosEnMemoria(const []),
    );
    movimientos = ControladorMovimientos(
      RepositorioMovimientosEnMemoria([
        Movimiento(
          id: 'm1',
          fecha: hoy,
          tipo: TipoMovimiento.venta,
          productoId: 'q',
          producto: 'Queso blanco duro',
          forma: FormaConteo.porKilo,
          marca: 'A',
          cantidad: 1000,
          importe: 1000,
          costo: 700,
          ventaId: 'v1',
        ),
      ]),
      ahora: () => hoy,
    );
    await movimientos.cargar();
    compras = ControladorCompras(RepositorioComprasEnMemoria(), existencias);
    gastos = ControladorGastos(RepositorioGastosEnMemoria());
    exportador = _ExportadorFalso();
  });

  Future<void> mostrar(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro(),
        home: PantallaReportes(
          movimientos: movimientos,
          existencias: existencias,
          compras: compras,
          gastos: gastos,
          exportador: exportador,
        ),
      ),
    );
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

  testWidgets('starts on this month\'s sales', (tester) async {
    await mostrar(tester);
    expect(find.text(r'$ 10,00'), findsWidgets);
    expect(find.textContaining('Este mes'), findsWidgets);
  });

  testWidgets('Alt+2 shows the profit of each product', (tester) async {
    await mostrar(tester);
    await atajo(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.digit2);
    expect(find.text('30 %'), findsOneWidget);
    expect(find.text(r'$ 3,00'), findsWidgets);
  });

  testWidgets('Ctrl+P and Ctrl+E export the report on screen', (tester) async {
    await mostrar(tester);
    await atajo(tester, LogicalKeyboardKey.altLeft, LogicalKeyboardKey.digit6);
    await atajo(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyP,
    );
    await atajo(
      tester,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.keyE,
    );
    expect(exportador.exportados, ['pdf Gastos', 'excel Gastos']);
  });
}
