import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/inventory_card.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/utils/display_formatters.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/view_models/lot_form_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LotFormScreen extends StatefulWidget {
  const LotFormScreen({super.key, this.id});
  final int? id;
  @override
  State<LotFormScreen> createState() => _LotFormScreenState();
}

class _LotFormScreenState extends State<LotFormScreen> {
  final _form = GlobalKey<FormState>();
  final _product = TextEditingController();
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _unit = TextEditingController();
  late final LotFormViewModel model;
  String? _field;
  String? _operator;
  String? _image;
  String? _imageName;
  DateTime? _expires;
  bool _active = true;
  bool _highlighted = false;

  @override
  void initState() {
    super.initState();
    model = LotFormViewModel(id: widget.id);
    _load();
  }

  Future<void> _load() async {
    await model.load();
    if (!mounted) return;
    final existing = model.existing;
    if (existing != null) {
      setState(() {
        _product.text = existing.produto;
        _quantity.text = existing.quantidade.toString();
        _price.text = existing.precoUnitario == 0
            ? ''
            : existing.precoUnitario.toStringAsFixed(2).replaceAll('.', ',');
        _unit.text = existing.unidadeMedida;
        _field = existing.talhaoId;
        _operator = existing.operadorId;
        _image = existing.imagemBase64;
        _imageName = existing.imagemNomeArquivo;
        _expires = existing.dataValidade;
        _active = existing.status != 'INATIVO';
        _highlighted = existing.isPublished;
      });
    }
  }

  @override
  void dispose() {
    _product.dispose();
    _quantity.dispose();
    _price.dispose();
    _unit.dispose();
    model.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await LocalImageService.pickImage();
      if (!mounted || image == null) return;
      setState(() {
        _image = image.base64Data;
        _imageName = image.fileName;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Não foi possível abrir a imagem. Tente outra foto.')));
      }
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
        context: context,
        initialDate: _expires ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 30),
        helpText: 'Validade do lote');
    if (mounted && selected != null) {
      setState(() {
        _expires = selected;
      });
    }
  }

  Future<void> _finish(String message) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      await FlowNavigation.goToRoot(context);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final success = await model.save(
        product: _product.text,
        fieldId: _field!,
        operatorId: _operator!,
        quantity: int.parse(_quantity.text),
        price: LotFormViewModel.parsePrice(_price.text)!,
        unit: _unit.text,
        active: _active,
        highlighted: _highlighted,
        image: _image,
        imageName: _imageName,
        expires: _expires);
    if (!mounted) return;
    if (success) {
      await _finish(widget.id == null
          ? 'Lote cadastrado com sucesso.'
          : 'Lote atualizado com sucesso.');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(model.error!)));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Excluir lote?'),
                content: const Text(
                    'O lote será removido permanentemente do estoque.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'))
                ]));
    if (confirmed != true || !mounted) return;
    final success = await model.delete();
    if (!mounted) return;
    if (success) {
      await _finish('Lote excluído.');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(model.error!)));
    }
  }

  InputDecoration _decoration(String label, IconData icon, {String? helper}) =>
      InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          helperText: helper,
          helperMaxLines: 2);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBarComponent(
            title: widget.id == null ? 'Cadastrar lote' : 'Editar lote',
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
            child: AnimatedBuilder(
                animation: model,
                builder: (context, _) {
                  if (model.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (model.error != null &&
                      model.existing == null &&
                      (widget.id != null || model.operators.isEmpty)) {
                    return Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(model.error!),
                      TextButton(
                          onPressed: _load,
                          child: const Text('Tentar novamente'))
                    ]));
                  }
                  return SingleChildScrollView(
                      child: Center(
                          child: Container(
                    constraints: const BoxConstraints(maxWidth: 760),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                        key: _form,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Informações do lote',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 8),
                              const Text(
                                  'Organize o estoque e acompanhe a disponibilidade dos produtos.'),
                              const SizedBox(height: 24),
                              TextFormField(
                                  controller: _product,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: _decoration('Nome do produto',
                                      Icons.inventory_2_outlined),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Informe o produto.'
                                          : null),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                  key: ValueKey('field:$_field'),
                                  initialValue: model.fields.any((row) =>
                                          row['id_local'].toString() == _field)
                                      ? _field
                                      : null,
                                  isExpanded: true,
                                  decoration: _decoration(
                                      'Talhão de origem', Icons.grass_outlined),
                                  items: model.fields
                                      .map((row) => DropdownMenuItem(
                                          value: row['id_local'].toString(),
                                          child: Text(DisplayFormatters.value(
                                              row['nome']))))
                                      .toList(),
                                  onChanged: (value) => setState(() {
                                        _field = value;
                                      }),
                                  validator: (value) => value == null
                                      ? 'Selecione um talhão da empresa.'
                                      : null),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                  key: ValueKey('operator:$_operator'),
                                  initialValue: model.operators.any((row) =>
                                          row['id_local'].toString() ==
                                          _operator)
                                      ? _operator
                                      : null,
                                  isExpanded: true,
                                  decoration: _decoration(
                                      'Operador responsável',
                                      Icons.badge_outlined),
                                  items: model.operators
                                      .map((row) => DropdownMenuItem(
                                          value: row['id_local'].toString(),
                                          child: Text(DisplayFormatters.value(
                                              row['nome_completo']))))
                                      .toList(),
                                  onChanged: (value) => setState(() {
                                        _operator = value;
                                      }),
                                  validator: (value) => value == null
                                      ? 'Selecione um operador da empresa.'
                                      : null),
                              if (model.fields.isEmpty ||
                                  model.operators.isEmpty) ...[
                                const SizedBox(height: 12),
                                const Text(
                                    'Cadastre um operador e um talhão antes de adicionar lotes.'),
                              ],
                              const SizedBox(height: 20),
                              TextFormField(
                                  controller: _quantity,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: _decoration(
                                      'Quantidade em estoque', Icons.numbers),
                                  validator: (value) =>
                                      int.tryParse(value ?? '') == null
                                          ? 'Informe uma quantidade inteira.'
                                          : null),
                              const SizedBox(height: 20),
                              TextFormField(
                                  controller: _unit,
                                  decoration: _decoration(
                                      'Unidade de medida', Icons.scale_outlined,
                                      helper:
                                          'Exemplos: kg, caixa, unidade ou saca.'),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Informe a unidade de medida.'
                                          : null),
                              const SizedBox(height: 20),
                              TextFormField(
                                  controller: _price,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: _decoration(
                                      'Preço por unidade (R\$)',
                                      Icons.payments_outlined,
                                      helper:
                                          'Deixe em branco para definir o preço depois.'),
                                  validator: (value) =>
                                      LotFormViewModel.parsePrice(
                                                  value ?? '') ==
                                              null
                                          ? 'Use um valor como 12,50.'
                                          : null),
                              const SizedBox(height: 20),
                              Card(
                                  margin: EdgeInsets.zero,
                                  child: ListTile(
                                    leading: const Icon(Icons.event_outlined),
                                    title: const Text('Validade (opcional)'),
                                    subtitle: Text(_expires == null
                                        ? 'Não informada'
                                        : DisplayFormatters.date(_expires)),
                                    onTap: _pickExpiry,
                                    trailing: _expires == null
                                        ? const Icon(Icons.calendar_month)
                                        : IconButton(
                                            tooltip: 'Remover validade',
                                            onPressed: () => setState(() {
                                                  _expires = null;
                                                }),
                                            icon: const Icon(Icons.close)),
                                  )),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Lote ativo'),
                                  subtitle: const Text(
                                      'Identifique os lotes disponíveis para a operação.'),
                                  value: _active,
                                  onChanged: (value) => setState(() {
                                        _active = value;
                                      })),
                              SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Destacar no catálogo'),
                                  subtitle: const Text(
                                      'Permite encontrar o lote pelo filtro Em destaque.'),
                                  value: _highlighted,
                                  onChanged: (value) => setState(() {
                                        _highlighted = value;
                                      })),
                              const SizedBox(height: 16),
                              InventoryImage(base64: _image, height: 200),
                              const SizedBox(height: 12),
                              Wrap(spacing: 12, children: [
                                OutlinedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(
                                        Icons.photo_library_outlined),
                                    label: Text(_image == null
                                        ? 'Escolher foto'
                                        : 'Trocar foto')),
                                if (_image != null)
                                  TextButton.icon(
                                      onPressed: () => setState(() {
                                            _image = null;
                                            _imageName = null;
                                          }),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Remover foto'))
                              ]),
                              const SizedBox(height: 28),
                              FilledButton.icon(
                                  onPressed: model.saving ? null : _save,
                                  icon: model.saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.check),
                                  label: Text(model.saving
                                      ? 'Salvando…'
                                      : 'Salvar lote')),
                              if (widget.id != null) ...[
                                const SizedBox(height: 16),
                                TextButton.icon(
                                    onPressed: model.saving ? null : _delete,
                                    icon: Icon(Icons.delete_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                    label: Text('Excluir lote',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error)))
                              ],
                            ])),
                  )));
                })),
      );
}
