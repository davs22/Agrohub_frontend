import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/services/theme_service.dart';
import 'package:flutter/material.dart';

class ConfiguracoesOperadorScreen extends StatefulWidget {
  const ConfiguracoesOperadorScreen({super.key});

  @override
  State<ConfiguracoesOperadorScreen> createState() => _ConfiguracoesOperadorScreenState();
}

class _ConfiguracoesOperadorScreenState extends State<ConfiguracoesOperadorScreen> {
  ThemeMode get _themeMode => ThemeService.notifier.value;

  Future<void> _setTheme(bool darkMode) async {
    await ThemeService.setThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);
    if (!mounted) return;
    setState(() {});
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
          DrawerMenuOption.homeOperador,
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
          ],
        ),
      ),
    );
  }
}
