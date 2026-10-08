import 'package:agrohub_app/components/form_page.dart';
import 'package:agrohub_app/components/input.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/utils/login_validators.dart';
import 'package:agrohub_app/view_models/record_form_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManagementFormScreen extends StatefulWidget {
  const ManagementFormScreen({super.key, required this.table, this.id});
  final String table;
  final int? id;
  @override
  State<ManagementFormScreen> createState() => _ManagementFormScreenState();
}

class _ManagementFormScreenState extends State<ManagementFormScreen> {
  late final RecordFormViewModel model;
  final controllers = <String, TextEditingController>{};
  bool active = true;
  String? operatorId;
  bool get isOperator => widget.table == 'operadores';
  String get noun => isOperator ? 'operador' : 'talhão';

  @override
  void initState() {
    super.initState();
    model = RecordFormViewModel(table: widget.table, id: widget.id);
    for (final key in isOperator ? ['nome_completo', 'cpf', 'telefone', 'email', 'senha'] : ['nome', 'tamanho_hectares', 'cultura_atual']) {
      controllers[key] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    await model.load();
    if (!mounted) return;
    for (final entry in controllers.entries) {
      if (entry.key != 'senha') entry.value.text = model.record[entry.key]?.toString() ?? '';
    }
    setState(() {
      active = model.record['status'] != 'INATIVO';
      operatorId = model.record['usuario_id']?.toString();
    });
  }

  @override
  void dispose() {
    for (final controller in controllers.values) { controller.dispose(); }
    model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await model.save({
      for (final entry in controllers.entries) entry.key: entry.value.text,
      if (!isOperator) 'usuario_id': operatorId ?? '',
    }, active: active);
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${isOperator ? 'Operador' : 'Talhão'} salvo com sucesso.')));
      await FlowNavigation.goToRoot(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text('Excluir $noun?'),
      content: const Text('Esta ação não pode ser desfeita. Cadastros com vínculos devem ser desativados para preservar o histórico.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    if (await model.delete() && mounted) await FlowNavigation.goToRoot(context);
  }

  Widget _field(String key, String label, IconData icon, {TextInputType? type, List<TextInputFormatter>? formatters}) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: InputComponent(
      label: label, emoji: icon, controll: controllers[key], typeInput: type,
      inputFormatters: formatters, errorText: model.errors[key], ephemeral: key == 'senha',
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) => FormPage(
      title: '${widget.id == null ? 'Cadastrar' : 'Editar'} $noun',
      headerDrawerTitle: 'Administrador', visibleOptions: const {},
      isLoading: model.busy || !model.ready, onSubmit: _save, submitLabel: 'Salvar',
      fields: [
        if (model.error != null) Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(model.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
        if (model.ready) ...[
          if (isOperator) ...[
            _field('nome_completo', 'Nome completo', Icons.person_outline),
            _field('cpf', 'CPF', Icons.badge_outlined, type: TextInputType.number, formatters: [CpfInputFormatter()]),
            _field('telefone', 'Telefone com DDD', Icons.phone_outlined, type: TextInputType.phone, formatters: [PhoneInputFormatter()]),
            _field('email', 'E-mail', Icons.mail_outline, type: TextInputType.emailAddress),
            _field('senha', widget.id == null ? 'Senha de acesso' : 'Nova senha (opcional)', Icons.lock_outline),
          ] else ...[
            _field('nome', 'Nome do talhão', Icons.grass),
            DropdownButtonFormField<String>(
              initialValue: model.operators.any((row) => row['id_local'].toString() == operatorId) ? operatorId : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: 'Operador responsável', errorText: model.errors['usuario_id'], prefixIcon: const Icon(Icons.person_outline)),
              items: model.operators.map((row) => DropdownMenuItem(value: row['id_local'].toString(), child: Text(row['nome_completo'].toString(), overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (value) => setState(() => operatorId = value),
            ),
            if (model.operators.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Cadastre um operador para associá-lo ao talhão.')),
            const SizedBox(height: 20),
            _field('tamanho_hectares', 'Área em hectares', Icons.square_foot, type: const TextInputType.numberWithOptions(decimal: true)),
            _field('cultura_atual', 'Cultura atual', Icons.eco_outlined),
          ],
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero, title: const Text('Cadastro ativo'),
            subtitle: const Text('Desative para manter os dados no histórico.'),
            value: active, onChanged: (value) => setState(() => active = value),
          ),
          if (widget.id != null) ...[
            const SizedBox(height: 20),
            TextButton.icon(onPressed: model.busy ? null : _delete, icon: const Icon(Icons.delete_outline), label: Text('Excluir $noun'), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error)),
          ],
        ],
      ],
    ),
  );
}
