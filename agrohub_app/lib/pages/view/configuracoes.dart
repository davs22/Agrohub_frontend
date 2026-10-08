import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/pages/view/perfil.dart';
import 'package:agrohub_app/pages/view/excluir_conta.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/services/theme_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});
  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}
class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final _session = SessionService.loadSession();
  @override
  Widget build(BuildContext context) => FlowBackGuard(child: Scaffold(
    appBar: AppBarComponent(title: 'Configurações', automaticallyImplyLeading: false, actions: [
      IconButton(tooltip: 'Voltar ao início', onPressed: () => FlowNavigation.goToRoot(context), icon: const Icon(Icons.home_outlined)),
      Builder(builder: (context) => IconButton(tooltip: 'Abrir menu', onPressed: () => Scaffold.of(context).openEndDrawer(), icon: const Icon(Icons.menu))),
    ]),
    endDrawer: const DrawerMenuComponent(),
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: ListView(
      padding: const EdgeInsets.all(24), children: [
        Text('Aparência', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.notifier,
          builder: (context, mode, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Tema do aplicativo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Sua preferência é mantida ao abrir o aplicativo novamente.'),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              initialValue: mode, decoration: const InputDecoration(labelText: 'Tema'),
              items: const [
                DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Escuro')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('Acompanhar o dispositivo')),
              ],
              onChanged: (value) { if (value != null) ThemeService.setThemeMode(value); },
            ),
          ]),
        ))),
        const SizedBox(height: 24),
        FutureBuilder<SessionData?>(future: _session, builder: (context, snapshot) {
          final session = snapshot.data;
          if (session == null || (!session.isAdmin && !session.isOperator)) return const SizedBox.shrink();
          return Column(children: [
            Card(child: ListTile(contentPadding: const EdgeInsets.all(20), leading: const Icon(Icons.account_circle_outlined), title: const Text('Meu perfil'), subtitle: const Text('Escolha uma foto ou um avatar para sua conta.'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen())))),
            if (session.isAdmin) ...[
              const SizedBox(height: 24),
              Card(child: ListTile(contentPadding: const EdgeInsets.all(20), leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), title: const Text('Excluir empresa'), subtitle: const Text('Gerencie a exclusão do cadastro da empresa.'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExcluirContaScreen())))),
            ],
          ]);
        }),
      ],
    )))),
  ));
}
