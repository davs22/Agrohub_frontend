import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/data_grid.dart';
import 'package:agrohub_app/components/session_drawer.dart';
import 'package:agrohub_app/models/financial_entry.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/view_models/finance_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late final FinanceViewModel model;

  @override
  void initState() {
    super.initState();
    model = FinanceViewModel()..load();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _edit([FinancialEntry? entry]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FinanceForm(entry: entry, model: model),
    );
    if (saved == true && mounted) await model.load();
  }

  Future<void> _delete(FinancialEntry entry) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Excluir lançamento?'),
              content: Text(
                  'O lançamento "${entry.description}" será removido dos indicadores. Esta ação não pode ser desfeita.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Excluir')),
              ],
            ));
    if (confirmed == true && mounted && entry.id != null) {
      await model.delete(entry.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FlowBackGuard(
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('Novo lançamento'),
        ),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: model,
            builder: (context, _) {
              final summary = model.summary;
              return RefreshIndicator(
                onRefresh: model.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  children: [
                    Text(
                      'Financeiro',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Acompanhe receitas, despesas, lucro e a margem do período.',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<FinancePeriod>(
                      segments: const [
                        ButtonSegment(
                            value: FinancePeriod.month, label: Text('Mês')),
                        ButtonSegment(
                            value: FinancePeriod.year, label: Text('Ano')),
                        ButtonSegment(
                            value: FinancePeriod.all, label: Text('Tudo')),
                      ],
                      selected: {model.period},
                      onSelectionChanged: (value) =>
                          model.setPeriod(value.first),
                    ),
                    const SizedBox(height: 16),
                    DataGrid<_SummaryTile>(
                      items: [
                        _SummaryTile(
                            'Receitas',
                            DisplayFormatters.currency(summary.income),
                            colors.primary),
                        _SummaryTile(
                            'Despesas',
                            DisplayFormatters.currency(summary.expense),
                            colors.error),
                        _SummaryTile(
                            'Resultado',
                            DisplayFormatters.currency(summary.balance),
                            colors.tertiary),
                        _SummaryTile(
                          'Margem',
                          summary.margin == null
                              ? 'Sem receita'
                              : '${DisplayFormatters.number(summary.margin!)}%',
                          colors.secondary,
                        ),
                      ],
                      itemHeight: 148,
                      itemBuilder: (context, tile) => Card(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tile.label,
                                  style: TextStyle(
                                      color: colors.onSurfaceVariant)),
                              const SizedBox(height: 16),
                              Text(
                                tile.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: tile.color,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DataSearchToolbar(
                      filter: model.type?.code ?? 'all',
                      filters: const {
                        'all': 'Todos',
                        'RECEITA': 'Receitas',
                        'DESPESA': 'Despesas',
                      },
                      onFilterChanged: (value) {
                        model.setType(value == 'all'
                            ? null
                            : FinancialEntryType.values
                                .firstWhere((type) => type.code == value));
                      },
                      onSearch: model.setSearch,
                      searchHint: 'Pesquisar lançamentos',
                    ),
                    const SizedBox(height: 18),
                    if (model.loading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (model.error != null)
                      Text(model.error!, style: TextStyle(color: colors.error))
                    else if (model.visibleEntries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                            child: Text('Nenhum lançamento encontrado.')),
                      )
                    else
                      DataGrid<FinancialEntry>(
                        items: model.pageEntries,
                        itemHeight: 280,
                        itemBuilder: (context, entry) => Card(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(entry.category,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant)),
                                const SizedBox(height: 8),
                                Text(
                                  DisplayFormatters.currency(entry.amount),
                                  style: TextStyle(
                                    color:
                                        entry.type == FinancialEntryType.income
                                            ? colors.primary
                                            : colors.error,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    '${entry.type.label} • ${DisplayFormatters.date(entry.date)}'),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar',
                                      onPressed: () => _edit(entry),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir',
                                      onPressed:
                                          entry.id == null || model.saving
                                              ? null
                                              : () => _delete(entry),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (!model.loading && model.visibleEntries.isNotEmpty)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                tooltip: 'Página anterior',
                                onPressed: model.page > 0
                                    ? () => model.goToPage(model.page - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left)),
                            Text(
                                'Página ${model.page + 1} de ${model.pageCount}'),
                            IconButton(
                                tooltip: 'Próxima página',
                                onPressed: model.page + 1 < model.pageCount
                                    ? () => model.goToPage(model.page + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right)),
                          ]),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryTile {
  const _SummaryTile(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
}

class _FinanceForm extends StatefulWidget {
  const _FinanceForm({required this.model, this.entry});
  final FinanceViewModel model;
  final FinancialEntry? entry;

  @override
  State<_FinanceForm> createState() => _FinanceFormState();
}

class _FinanceFormState extends State<_FinanceForm> {
  late final TextEditingController description;
  late final TextEditingController category;
  late final TextEditingController amount;
  late DateTime date;
  late FinancialEntryType type;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    description = TextEditingController(text: entry?.description ?? '');
    category = TextEditingController(text: entry?.category ?? '');
    amount = TextEditingController(
      text: entry == null
          ? ''
          : NumberFormat('#,##0.00', 'pt_BR').format(entry.amount),
    );
    date = entry?.date ?? DateTime.now();
    type = entry?.type ?? FinancialEntryType.income;
  }

  @override
  void dispose() {
    description.dispose();
    category.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (saving) return;
    final cents = FinancialEntry.parseCents(amount.text);
    if (description.text.trim().isEmpty ||
        category.text.trim().isEmpty ||
        cents == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preencha descrição, categoria e um valor válido.')),
      );
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final ok = await widget.model.save(FinancialEntry(
      id: widget.entry?.id,
      description: description.text,
      category: category.text,
      type: type,
      amountCents: cents,
      date: date,
    ));
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        saving = false;
        error = widget.model.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + padding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.entry == null ? 'Novo lançamento' : 'Editar lançamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Valor', hintText: '0,00'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FinancialEntryType>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: FinancialEntryType.values
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => type = value);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data do movimento'),
              subtitle: Text(DisplayFormatters.date(date)),
              trailing: const Icon(Icons.event),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selected != null && mounted) {
                  setState(() => date = selected);
                }
              },
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            FilledButton(
                onPressed: saving ? null : _save,
                child: Text(saving ? 'Salvando...' : 'Salvar')),
          ],
        ),
      ),
    );
  }
}
