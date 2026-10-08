import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/profile_avatar.dart';
import 'package:agrohub_app/pages/view/lotes.dart';
import 'package:agrohub_app/pages/view/marketplace.dart';
import 'package:agrohub_app/pages/view/perfil_operador.dart';
import 'package:agrohub_app/pages/view/talhoes_operador.dart';
import 'package:agrohub_app/view_models/operator_home_view_model.dart';
import 'package:flutter/material.dart';

class HomeOperadorScreen extends StatefulWidget {
  const HomeOperadorScreen({super.key});
  @override
  State<HomeOperadorScreen> createState() => _HomeOperadorScreenState();
}

class _HomeOperadorScreenState extends State<HomeOperadorScreen> {
  final model = OperatorHomeViewModel();
  @override
  void initState() { super.initState(); model.load(); }
  @override
  void dispose() { model.dispose(); super.dispose(); }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) await model.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBarComponent(title: 'AgroHub', automaticallyImplyLeading: false, actions: [
      Builder(builder: (context) => IconButton(tooltip: 'Abrir menu', icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openEndDrawer())),
    ]),
    endDrawer: const DrawerMenuComponent(),
    body: SafeArea(child: ListenableBuilder(listenable: model, builder: (context, _) {
      if (model.loading) return const Center(child: CircularProgressIndicator());
      if (model.error != null) {
        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(model.error!), const SizedBox(height: 16),
        FilledButton(onPressed: model.load, child: const Text('Tentar novamente')),
      ]));
      }
      return RefreshIndicator(onRefresh: model.load, child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: ListView(padding: const EdgeInsets.all(24), children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            ActionChip(avatar: const Icon(Icons.inventory_2_outlined, size: 18), label: const Text('Estoque'), onPressed: () => _open(const MarketplaceScreen())),
            ActionChip(avatar: const Icon(Icons.landscape_outlined, size: 18), label: const Text('Talhões'), onPressed: () => _open(const ViewTalhaoOperadorScreen())),
            ActionChip(avatar: const Icon(Icons.layers_outlined, size: 18), label: const Text('Lotes'), onPressed: () => _open(const ViewLoteScreen())),
            ActionChip(avatar: const Icon(Icons.person_outline, size: 18), label: const Text('Meu perfil'), onPressed: () => _open(const PerfilOperadorScreen())),
          ]),
          const SizedBox(height: 24),
          Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SessionProfileAvatar(radius: 36), const SizedBox(height: 16),
            Text('Olá, ${model.session?.displayName ?? 'operador'}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Acompanhe os talhões e o estoque da sua empresa.'),
          ]))),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) => Wrap(spacing: 16, runSpacing: 16, children: [
            for (final item in [
              ('Talhões', model.fieldCount, Icons.landscape_outlined),
              ('Lotes', model.lotCount, Icons.inventory_2_outlined),
              ('Vencem em até 30 dias', model.expiringCount, Icons.event_outlined),
            ]) SizedBox(width: constraints.maxWidth >= 650 ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
              child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
                Icon(item.$3, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12),
                Text('${item.$2}', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), Text(item.$1),
              ])))),
          ])),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () => _open(const MarketplaceScreen()), icon: const Icon(Icons.search), label: const Text('Consultar produtos e quantidades')),
        ]),
      )));
    })),
  );
}
