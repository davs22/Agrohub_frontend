import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/session_drawer.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/view_models/account_action_view_model.dart';
import 'package:flutter/material.dart';

class ExcluirContaScreen extends StatefulWidget {
  const ExcluirContaScreen({super.key});

  @override
  State<ExcluirContaScreen> createState() => _ExcluirContaScreenState();
}

class _ExcluirContaScreenState extends State<ExcluirContaScreen> {
  final _password = TextEditingController();
  final _model = AccountActionViewModel();
  bool _confirmed = false;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _model.loadCompany();
  }

  @override
  void dispose() {
    _password.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_model.busy || _confirming || !_confirmed || _model.company == null) return;
    _confirming = true;
    final accepted = await showDialog<bool>(context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão local'),
        content: Text('Excluir ${_model.company!.name} e todos os dados locais ligados a esta empresa? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir empresa')),
        ],
      ));
    _confirming = false;
    if (accepted != true || !mounted) return;
    final success = await _model.deleteCompany(_password.text);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_model.error ?? 'Não foi possível excluir a empresa.')));
      return;
    }
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginComercioScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => FlowBackGuard(child: Scaffold(
    appBar: const AppBarComponent(title: 'AgroHub'),
    endDrawer: const SessionAwareDrawer(),
    body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 540),
      child: AnimatedBuilder(animation: _model, builder: (context, _) =>
        ListView(padding: const EdgeInsets.all(24), children: [
          Text('Excluir empresa', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (_model.company == null)
            Text(_model.error ?? 'Carregando empresa da sessão...')
          else ...[
            Text('Empresa da sessão: ${_model.company!.name} (${_model.company!.document})'),
            const SizedBox(height: 12),
            const Text('A exclusão apaga desta instalação a empresa, seus operadores, talhões, lotes, itens de carrinho associados e lançamentos financeiros. Os dados de outras empresas são preservados.'),
            const SizedBox(height: 20),
            TextField(controller: _password, obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha administrativa atual', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            CheckboxListTile(value: _confirmed, contentPadding: EdgeInsets.zero,
                title: const Text('Entendo que a exclusão local é permanente.'),
                onChanged: _model.busy ? null : (value) => setState(() => _confirmed = value ?? false)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _model.busy || !_confirmed ? null : _delete,
                child: Text(_model.busy ? 'Excluindo...' : 'Excluir empresa e dados relacionados')),
          ],
        ])),
    ))),
  ));
}
