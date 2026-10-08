import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/data_grid.dart';
import 'package:agrohub_app/components/inventory_card.dart';
import 'package:agrohub_app/components/session_drawer.dart';
import 'package:agrohub_app/pages/edit/lote.dart';
import 'package:agrohub_app/pages/edit/operador.dart';
import 'package:agrohub_app/pages/edit/talhao.dart';
import 'package:agrohub_app/pages/registro/lote.dart';
import 'package:agrohub_app/pages/registro/operador.dart';
import 'package:agrohub_app/pages/registro/talhao.dart';
import 'package:agrohub_app/pages/view/detalhe_produto.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/view_models/inventory_view_model.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key, required this.kind});
  final InventoryKind kind;
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryViewModel model;
  @override
  void initState() {
    super.initState();
    model = InventoryViewModel(widget.kind)..load();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  String get title => switch (widget.kind) {
        InventoryKind.catalog => 'Estoque',
        InventoryKind.lots => 'Lotes',
        InventoryKind.fields => 'Talhões',
        InventoryKind.operators => 'Operadores',
      };
  bool get isLot =>
      widget.kind == InventoryKind.catalog || widget.kind == InventoryKind.lots;

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) await model.load();
  }

  Widget _edit(int id) => switch (widget.kind) {
        InventoryKind.operators => EditOperadorScreen(idLocal: id),
        InventoryKind.fields => EditTalhaoScreen(idLocal: id),
        _ => EditLoteScreen(idLocal: id),
      };
  Widget _create() => switch (widget.kind) {
        InventoryKind.operators => const RegisterOperadorScreen(),
        InventoryKind.fields => const RegisterTalhaoScreen(),
        _ => const RegisterLoteScreen(),
      };

  void _details(Map<String, dynamic> record) {
    if (isLot) {
      _open(ProductDetailScreen(idLocal: record['id_local'] as int));
      return;
    }
    final isOperator = widget.kind == InventoryKind.operators;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DisplayFormatters.value(
            record[isOperator ? 'nome_completo' : 'nome'])),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DataLabel(
                    'Situação', DisplayFormatters.status(record['status'])),
                if (isOperator) ...[
                  DataLabel('CPF', DisplayFormatters.document(record['cpf'])),
                  DataLabel(
                      'Telefone', DisplayFormatters.phone(record['telefone'])),
                  DataLabel('E-mail', DisplayFormatters.value(record['email'])),
                ] else ...[
                  DataLabel('Cultura atual',
                      DisplayFormatters.value(record['cultura_atual'])),
                  DataLabel(
                    'Área',
                    '${DisplayFormatters.number(num.tryParse(record['tamanho_hectares'].toString()) ?? 0)} hectares',
                  ),
                  DataLabel('Responsável',
                      DisplayFormatters.value(record['operador_nome'])),
                ],
                DataLabel('Cadastrado em',
                    DisplayFormatters.date(record['data_registro'])),
                DataLabel('Última atualização',
                    DisplayFormatters.date(record['data_atualizacao'])),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FlowBackGuard(
        child: Scaffold(
          appBar: AppBarComponent(
            title: 'AgroHub',
            automaticallyImplyLeading: false,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Abrir menu',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              ),
            ],
          ),
          endDrawer: const SessionAwareDrawer(),
          body: SafeArea(
            child: AnimatedBuilder(
              animation: model,
              builder: (context, _) => RefreshIndicator(
                onRefresh: model.load,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isLot
                                      ? 'Consulte preços, quantidades e validade de cada produto.'
                                      : 'Organize e acompanhe os dados da sua empresa.',
                                ),
                              ],
                            ),
                            if (model.canManage)
                              FilledButton.icon(
                                onPressed: () => _open(_create()),
                                icon: const Icon(Icons.add),
                                label: Text(switch (widget.kind) {
                                  InventoryKind.operators => 'Novo operador',
                                  InventoryKind.fields => 'Novo talhão',
                                  _ => 'Novo lote',
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        DataSearchToolbar(
                          filter: model.filter,
                          filters: {
                            'all': 'Todos',
                            'active': 'Ativos',
                            'inactive': 'Inativos',
                            if (isLot) ...{
                              'stock': 'Com estoque',
                              'empty': 'Sem estoque',
                              'expired': 'Vencidos',
                              'published': 'Em destaque',
                            },
                          },
                          onFilterChanged: model.setFilter,
                          onSearch: model.search,
                          searchHint: 'Pesquisar ${title.toLowerCase()}',
                        ),
                        const SizedBox(height: 18),
                        if (model.loading)
                          const Padding(
                            padding: EdgeInsets.all(80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (model.error != null)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Text(model.error!),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: model.load,
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          )
                        else if (model.total == 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 64),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 48),
                                SizedBox(height: 16),
                                Text('Nenhum resultado encontrado.'),
                                SizedBox(height: 8),
                                Text(
                                    'Altere a pesquisa ou o filtro para tentar novamente.'),
                              ],
                            ),
                          )
                        else ...[
                          Text(
                            '${model.total} ${model.total == 1 ? 'registro encontrado' : 'registros encontrados'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          DataGrid<Map<String, dynamic>>(
                            items: model.pageRecords,
                            itemHeight: isLot ? 500 : 410,
                            itemBuilder: (context, record) => InventoryCard(
                              kind: widget.kind,
                              record: record,
                              onDetails: () => _details(record),
                              onEdit: model.canManage
                                  ? () =>
                                      _open(_edit(record['id_local'] as int))
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Página anterior',
                                onPressed: model.page > 0
                                    ? () => model.goToPage(model.page - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              Text(
                                  'Página ${model.page + 1} de ${model.pageCount}'),
                              IconButton(
                                tooltip: 'Próxima página',
                                onPressed: model.page + 1 < model.pageCount
                                    ? () => model.goToPage(model.page + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
