import 'dart:math' as math;
import 'package:agrohub_app/components/data_grid.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/components/inventory_card.dart';
import 'package:agrohub_app/theme/app_theme.dart';
import 'package:agrohub_app/view_models/inventory_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  return (math.max(a, b) + .05) / (math.min(a, b) + .05);
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    test('Contraste legível em textos e campos: ${theme.brightness}', () {
      final scheme = theme.colorScheme;
      expect(contrast(scheme.onSurface, scheme.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(scheme.onSurfaceVariant, theme.inputDecorationTheme.fillColor!), greaterThanOrEqualTo(4.5));
      expect(contrast(scheme.onPrimary, scheme.primary), greaterThanOrEqualTo(4.5));
    });
    testWidgets('Campos mantêm texto, rótulo e erro visíveis: ${theme.brightness}', (tester) async {
      final controller = TextEditingController(text: '150,00');
      await tester.pumpWidget(MaterialApp(theme: theme, home: Scaffold(body: InputComponent(
        controll: controller, label: 'Preço', errorText: 'Confira o valor informado.',
      ))));
      expect(find.text('Preço'), findsOneWidget);
      expect(find.text('150,00'), findsOneWidget);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.style.color, theme.colorScheme.onSurface);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    });
  }

  for (final width in [360.0, 1200.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('Grade de produtos sem overflow em $width px e texto $scale', (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(theme: AppTheme.dark, home: MediaQuery(
          data: MediaQueryData(size: Size(width, 900), textScaler: TextScaler.linear(scale)),
          child: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            DataSearchToolbar(filter: 'all', filters: const {'all': 'Todos', 'active': 'Ativos'}, onFilterChanged: (_) {}, onSearch: (_) {}, searchHint: 'Pesquisar produtos'),
            const SizedBox(height: 20),
            DataGrid<int>(items: const [1, 2, 3, 4], itemHeight: 420, itemBuilder: (context, id) => InventoryCard(
              kind: InventoryKind.lots, record: const {
                'produto': 'Tomate orgânico selecionado para distribuição', 'status': 'ATIVO', 'preco_unitario': 1250.75,
                'quantidade': 12000, 'unidade_medida': 'kg', 'talhao_nome': 'Área de produção principal',
              }, onDetails: () {}, onEdit: () {},
            )),
          ])))),
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, width == 1200 ? 4 : 1);
      });
    }
  }
}
