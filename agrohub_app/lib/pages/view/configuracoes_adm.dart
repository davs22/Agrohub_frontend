import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/pages/view/excluir_conta.dart';
import 'package:agrohub_app/services/theme_service.dart';
import 'package:flutter/material.dart';

class ConfiguracoesAdmScreen extends StatefulWidget {
  const ConfiguracoesAdmScreen({super.key});

  @override
  State<ConfiguracoesAdmScreen> createState() => _ConfiguracoesAdmScreenState();
}

class _ConfiguracoesAdmScreenState extends State<ConfiguracoesAdmScreen> {
  ThemeMode get _themeMode => ThemeService.notifier.value;

  Future<void> _setTheme(bool darkMode) async {
    await ThemeService.setThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
    if (!mounted) return;
    setState(() {});
  }

  void _openDeleteAccountFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExcluirContaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBarComponent(
        title: 'AgroHub',
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
      endDrawer: const DrawerMenuComponent(
        headerTitle: 'Configuracoes',
        visibleOptions: {
          DrawerMenuOption.homeAdmin,
          DrawerMenuOption.listaOperadores,
          DrawerMenuOption.registrarOperador,
          DrawerMenuOption.registrarTalhao,
          DrawerMenuOption.registrarLote,
          DrawerMenuOption.marketplace,
          DrawerMenuOption.perfilOperador,
          DrawerMenuOption.carrinho,
          DrawerMenuOption.configuracoes,
          DrawerMenuOption.logout,
        },
        hiddenOptions: {
          DrawerMenuOption.configuracoes,
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TextComponent(
              text: 'Configuracoes',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextComponent(
                    text: 'Tema do aplicativo',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      isDark ? 'Tema escuro' : 'Tema claro',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('A escolha fica salva mesmo ao fechar o app.'),
                    value: isDark,
                    onChanged: _setTheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextComponent(
                    text: 'Exclusao permanente',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aqui voce pode excluir comercio ou fazenda com confirmacao de documento e codigo de verificacao.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  ButtonComponent(
                    label: 'Excluir comercio / fazenda',
                    icon: Icons.delete_forever,
                    width: double.infinity,
                    height: 48,
                    borderRadius: 8,
                    backgroundColor: Colors.red,
                    borderColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: _openDeleteAccountFlow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
