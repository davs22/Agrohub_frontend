import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/pages/edit/empresa.dart';
import 'package:agrohub_app/pages/view/finance_screen.dart';
import 'package:agrohub_app/pages/view/lotes.dart';
import 'package:agrohub_app/pages/view/marketplace.dart';
import 'package:agrohub_app/pages/view/operador.dart';
import 'package:agrohub_app/pages/view/talhoes.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/view_models/dashboard_view_model.dart';
import 'package:flutter/material.dart';

class HomeAdmScreen extends StatefulWidget {
  const HomeAdmScreen({super.key});

  @override
  State<HomeAdmScreen> createState() => _HomeAdmScreenState();
}

class _HomeAdmScreenState extends State<HomeAdmScreen> {
  final _viewModel = DashboardViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) await _viewModel.load();
  }

  Widget _shortcut(String label, IconData icon, Widget page) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          avatar: Icon(icon, size: 18),
          label: Text(label),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onPressed: () => _open(page),
        ),
      );

  Widget _metric(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: colors.primary, size: 25),
            const SizedBox(height: 10),
            Text(value,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }

  Widget _metricRow(List<Widget> cards) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children:
              cards.map((card) => SizedBox(width: width, child: card)).toList(),
        );
      });

  Widget _field(String label, String value, double width) => SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );

  Widget _companyCard() {
    final company = _viewModel.company!;
    final record = company.record;
    final fields = <String, String>{
      'Nome': company.name,
      'CPF / CNPJ': DisplayFormatters.document(company.document),
      if (company.isFarm)
        'Área total':
            '${DisplayFormatters.number(num.tryParse('${record['hectares']}') ?? 0)} ha',
      if (company.isFarm)
        'Localização':
            '${DisplayFormatters.value(record['latitude'])}, ${DisplayFormatters.value(record['longitude'])}',
      if (!company.isFarm) 'Endereço': DisplayFormatters.value(record['rua']),
      if (!company.isFarm) 'CEP': DisplayFormatters.cep(record['cep']),
      'Telefone': DisplayFormatters.phone(record['telefone']),
      'E-mail': DisplayFormatters.value(record['email']),
      'Situação': DisplayFormatters.status(record['status']),
      'Cadastro realizado em': DisplayFormatters.date(record['data_registro']),
      'Última atualização': DisplayFormatters.date(record['data_atualizacao']),
    };
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(company.isFarm ? Icons.agriculture : Icons.storefront,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    company.isFarm ? 'Dados da fazenda' : 'Dados do comércio',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760
                ? 3
                : constraints.maxWidth >= 440
                    ? 2
                    : 1;
            final width = (constraints.maxWidth - (columns - 1) * 24) / columns;
            return Wrap(
                spacing: 24,
                runSpacing: 20,
                children: fields.entries
                    .map((entry) => _field(entry.key, entry.value, width))
                    .toList());
          }),
          const SizedBox(height: 24),
          FilledButton.icon(
              onPressed: () => _open(EditEmpresaScreen(company: company)),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBarComponent(
          title: 'AgroHub',
          automaticallyImplyLeading: false,
          actions: [
            Builder(
                builder: (context) => IconButton(
                      tooltip: 'Abrir menu',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.menu),
                    ))
          ],
        ),
        endDrawer: const DrawerMenuComponent(headerTitle: 'Administrador'),
        body: SafeArea(
            child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_viewModel.error != null) {
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_viewModel.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: _viewModel.load,
                            child: const Text('Tentar novamente')),
                      ])));
            }
            final summary = _viewModel.summary;
            return RefreshIndicator(
              onRefresh: _viewModel.load,
              child: Center(
                  child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          _shortcut('Operadores', Icons.groups_outlined,
                              const ViewOperadorScreen()),
                          _shortcut('Talhões', Icons.grid_view_rounded,
                              const ViewTalhaoScreen()),
                          _shortcut('Lotes', Icons.inventory_2_outlined,
                              const ViewLoteScreen()),
                          _shortcut('Catálogo', Icons.storefront_outlined,
                              const MarketplaceScreen()),
                          _shortcut('Financeiro', Icons.insights_outlined,
                              const FinanceScreen()),
                        ])),
                    const SizedBox(height: 22),
                    _metricRow([
                      _metric('Operadores', '${_viewModel.operatorCount}',
                          Icons.groups_outlined,
                          onTap: () => _open(const ViewOperadorScreen())),
                      _metric('Talhões', '${_viewModel.plotCount}',
                          Icons.grid_view_rounded,
                          onTap: () => _open(const ViewTalhaoScreen())),
                      _metric('Lotes', '${_viewModel.lotCount}',
                          Icons.inventory_2_outlined,
                          onTap: () => _open(const ViewLoteScreen())),
                      _metric('Em destaque', '${_viewModel.catalogCount}',
                          Icons.storefront_outlined,
                          onTap: () => _open(const MarketplaceScreen())),
                    ]),
                    const SizedBox(height: 24),
                    _companyCard(),
                    const SizedBox(height: 28),
                    Text('Resumo financeiro do mês',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Receitas e despesas registradas pela empresa.',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    const SizedBox(height: 16),
                    _metricRow([
                      _metric(
                          'Receitas',
                          DisplayFormatters.currency(summary.income),
                          Icons.trending_up),
                      _metric(
                          'Despesas',
                          DisplayFormatters.currency(summary.expense),
                          Icons.trending_down),
                      _metric(
                          'Resultado',
                          DisplayFormatters.currency(summary.balance),
                          Icons.account_balance_wallet_outlined),
                      _metric(
                          'Margem do resultado',
                          summary.margin == null
                              ? '—'
                              : '${DisplayFormatters.number(summary.margin!)}%',
                          Icons.percent),
                    ]),
                    const SizedBox(height: 16),
                    Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Estoque a preço de venda: ${DisplayFormatters.currency(_viewModel.stockValue)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 8),
                                  Text(
                                      '${_viewModel.expiringLots} lote(s) com validade nos próximos 30 dias.'),
                                  const SizedBox(height: 8),
                                  Text(
                                      'O estoque é uma estimativa com os preços cadastrados. O resultado é a diferença entre receitas e despesas lançadas.',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                      onPressed: () =>
                                          _open(const FinanceScreen()),
                                      icon: const Icon(Icons.insights),
                                      label:
                                          const Text('Gerenciar financeiro')),
                                ]))),
                  ],
                ),
              )),
            );
          },
        )),
      );
}
