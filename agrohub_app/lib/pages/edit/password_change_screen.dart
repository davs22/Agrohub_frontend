import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/session_drawer.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/view_models/account_action_view_model.dart';
import 'package:flutter/material.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key, required this.admin});
  final bool admin;

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();
  final _model = AccountActionViewModel();
  late final Future<SessionData?> _session = SessionService.loadSession();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _model.changePassword(
        admin: widget.admin, current: _current.text,
        next: _next.text, confirmation: _confirmation.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        success ? 'Senha alterada nesta conta.' : _model.error ?? 'Falha ao alterar senha.')));
    if (success) {
      _current.clear();
      _next.clear();
      _confirmation.clear();
      await FlowNavigation.goToRoot(context);
    }
  }

  @override
  Widget build(BuildContext context) => FlowBackGuard(
    child: Scaffold(
      appBar: const AppBarComponent(title: 'AgroHub'),
      endDrawer: const SessionAwareDrawer(),
      body: FutureBuilder<SessionData?>(
        future: _session,
        builder: (context, snapshot) {
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = snapshot.data;
          final permitted = widget.admin ? session?.isAdmin ?? false
              : session?.isOperator ?? false;
          return SafeArea(child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(padding: const EdgeInsets.all(24), children: [
              Text('Alterar senha ${widget.admin ? 'administrativa' : 'de operação'}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              const Text('A alteração local exige uma sessão ativa e a senha atual da própria conta.'),
              const SizedBox(height: 8),
              const Text('Esqueceu a senha? A recuperação não está disponível sem um serviço de verificação de identidade.'),
              if (!permitted) ...[
                const SizedBox(height: 20),
                const Text('Entre no perfil correspondente para alterar a senha.'),
              ] else ...[
                const SizedBox(height: 24),
                Text('Conta: ${session!.displayName ?? session.login}'),
                const SizedBox(height: 20),
                TextField(controller: _current, obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha atual', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _next, obscureText: true,
                    decoration: const InputDecoration(labelText: 'Nova senha (mínimo 8 caracteres)', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _confirmation, obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirme a nova senha', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                AnimatedBuilder(animation: _model, builder: (context, _) =>
                    FilledButton(onPressed: _model.busy ? null : _submit,
                        child: Text(_model.busy ? 'Salvando...' : 'Alterar senha'))),
              ],
            ]),
          )));
        },
      ),
    ),
  );
}
