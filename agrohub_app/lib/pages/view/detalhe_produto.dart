import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/data_grid.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/inventory_card.dart';
import 'package:agrohub_app/pages/edit/lote.dart';
import 'package:agrohub_app/repositories/inventory_repository.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.idLocal});
  final int idLocal;
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final repository = const InventoryRepository();
  late Future<Map<String, dynamic>?> future;
  bool canManage = false;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<Map<String, dynamic>?> _load() async {
    canManage = await repository.canManage();
    return repository.lot(widget.idLocal);
  }

  Future<void> _edit() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditLoteScreen(idLocal: widget.idLocal)));
    if (mounted) {
      setState(() {
        future = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBarComponent(
            title: 'Detalhes do produto',
            automaticallyImplyLeading: true,
            actions: [
              Builder(
                  builder: (context) => IconButton(
                      tooltip: 'Abrir menu',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.menu)))
            ]),
        endDrawer: const DrawerMenuComponent(headerTitle: 'AgroHub'),
        body: SafeArea(
            child: FutureBuilder<Map<String, dynamic>?>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('Não foi possível carregar o produto.'),
                      TextButton(
                          onPressed: () => setState(() {
                                future = _load();
                              }),
                          child: const Text('Tentar novamente')),
                    ]));
                  }
                  final record = snapshot.data;
                  if (record == null) {
                    return const Center(
                        child: Text('Produto não encontrado nesta empresa.'));
                  }
                  final quantity =
                      num.tryParse(record['quantidade'].toString()) ?? 0;
                  final price =
                      num.tryParse(record['preco_unitario'].toString()) ?? 0;
                  return SingleChildScrollView(
                      child: Center(
                          child: Container(
                    constraints: const BoxConstraints(maxWidth: 850),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InventoryImage(
                              base64: record['imagem_base64']?.toString(),
                              height: 260),
                          const SizedBox(height: 24),
                          Text(DisplayFormatters.value(record['produto']),
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text(
                              price > 0
                                  ? '${DisplayFormatters.currency(price)} por ${DisplayFormatters.value(record['unidade_medida'])}'
                                  : 'Preço não definido',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                          const SizedBox(height: 24),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DataLabel('Quantidade em estoque',
                                            '${DisplayFormatters.number(quantity)} ${DisplayFormatters.value(record['unidade_medida'])}',
                                            icon: Icons.inventory_2_outlined),
                                        DataLabel(
                                            'Valor potencial do lote',
                                            DisplayFormatters.currency(
                                                price * quantity)),
                                        DataLabel(
                                            'Situação',
                                            DisplayFormatters.status(
                                                record['status'])),
                                        DataLabel(
                                            'Validade',
                                            DisplayFormatters.date(
                                                record['data_validade'])),
                                        DataLabel(
                                            'Talhão de origem',
                                            DisplayFormatters.value(
                                                record['talhao_nome'])),
                                        DataLabel(
                                            'Operador responsável',
                                            DisplayFormatters.value(
                                                record['operador_nome'])),
                                        if (record['codigo_rastreio'] != null)
                                          DataLabel(
                                              'Código de rastreio',
                                              DisplayFormatters.value(
                                                  record['codigo_rastreio'])),
                                        DataLabel(
                                            'Cadastrado em',
                                            DisplayFormatters.date(
                                                record['data_registro'])),
                                        DataLabel(
                                            'Última atualização',
                                            DisplayFormatters.date(
                                                record['data_atualizacao'])),
                                      ]))),
                          if (canManage) ...[
                            const SizedBox(height: 20),
                            FilledButton.icon(
                                onPressed: _edit,
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Editar lote'))
                          ],
                        ]),
                  )));
                })),
      );
}
