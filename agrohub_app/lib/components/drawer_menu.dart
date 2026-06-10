import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/constants.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/home_operador_screen.dart';
import 'package:agrohub_app/pages/login/adm.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/pages/login/operador.dart';
import 'package:agrohub_app/pages/edit/pass_adm.dart';
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/pages/registro/comercio.dart';
import 'package:agrohub_app/pages/registro/fazenda.dart';
import 'package:agrohub_app/pages/registro/lote.dart';
import 'package:agrohub_app/pages/registro/operador.dart';
import 'package:agrohub_app/pages/registro/talhao.dart';
import 'package:agrohub_app/pages/view/carrinho.dart';
import 'package:agrohub_app/pages/view/configuracoes.dart';
import 'package:agrohub_app/pages/view/lotes.dart';
import 'package:agrohub_app/pages/view/marketplace.dart';
import 'package:agrohub_app/pages/view/operador.dart';
import 'package:agrohub_app/pages/view/perfil_operador.dart';
import 'package:agrohub_app/pages/view/talhoes.dart';
import 'package:agrohub_app/pages/view/talhoes_operador.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

enum DrawerMenuOption {
  operador,
  inicio,
  administrador,
  homeAdmin,
  homeOperador,
  listaOperadores,
  novaSenhaAdmin,
  novaSenhaOperador,
  registrarFazenda,
  registrarComercio,
  registrarOperador,
  editarOperador,
  registrarTalhao,
  editarTalhao,
  registrarLote,
  editarLote,
  talhoes,
  carrinho,
  perfilOperador,
  marketplace,
  configuracoes,
  logout,
}

class DrawerItem {
  const DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
}

class DrawerMenuComponent extends StatelessWidget {
  const DrawerMenuComponent({
    super.key,
    this.headerTitle,
    this.headerSubtitle,
    this.headerIcon = Icons.account_circle,
    this.headerColor = componentPrimaryColor,
    this.backgroundColor,
    this.items,
    this.visibleOptions,
    this.hiddenOptions = const {},
  });

  final String? headerTitle;
  final String? headerSubtitle;
  final IconData headerIcon;
  final Color headerColor;
  final Color? backgroundColor;
  final List<DrawerItem>? items;
  final Set<DrawerMenuOption>? visibleOptions;
  final Set<DrawerMenuOption> hiddenOptions;

  @override
  Widget build(BuildContext context) {
    final resolvedItems = items ?? _buildDefaultItems(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: headerColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(headerIcon, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      if (headerTitle != null)
                        Text(
                          headerTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (headerSubtitle != null)
                        Text(
                          headerSubtitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                ...resolvedItems.map(
                  (item) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Icon(
                      item.icon,
                      color: item.iconColor ?? colorScheme.onSurface,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: item.textColor ?? colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: item.onTap,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: ButtonComponent(
                label: 'Sair',
                borderRadius: 10,
                width: 200,
                height: 50,
                onPressed: () {
                  SessionService.clearSession().then((_) {
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginComercioScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DrawerItem> _buildDefaultItems(BuildContext context) {
    final options = visibleOptions ?? DrawerMenuOption.values.toSet();

    return options
        .where((option) => !hiddenOptions.contains(option))
        .where((option) => option != DrawerMenuOption.logout)
        .map((option) => _buildItemFromOption(context, option))
        .toList();
  }

  DrawerItem _buildItemFromOption(
    BuildContext context,
    DrawerMenuOption option,
  ) {
    switch (option) {
      case DrawerMenuOption.operador:
        return DrawerItem(
          title: 'Operador',
          icon: Icons.manage_accounts,
          onTap: () => _navigateTo(context, const LoginOperadorScreen()),
        );
      case DrawerMenuOption.inicio:
        return DrawerItem(
          title: 'Tela inicial',
          icon: Icons.manage_accounts,
          onTap: () => _navigateTo(context, const LoginComercioScreen()),
        );
      case DrawerMenuOption.administrador:
        return DrawerItem(
          title: 'Administrador',
          icon: Icons.admin_panel_settings,
          onTap: () => _navigateTo(context, const LoginAdmScreen()),
        );
      case DrawerMenuOption.homeAdmin:
        return DrawerItem(
          title: 'Home Admin',
          icon: Icons.space_dashboard,
          onTap: () => _navigateTo(context, const HomeAdmScreen()),
        );
      case DrawerMenuOption.homeOperador:
        return DrawerItem(
          title: 'Home Operador',
          icon: Icons.home,
          onTap: () => _navigateTo(context, const HomeOperadorScreen()),
        );
      case DrawerMenuOption.listaOperadores:
        return DrawerItem(
          title: 'Operadores',
          icon: Icons.list,
          onTap: () => _navigateTo(context, const ViewOperadorScreen()),
        );
      case DrawerMenuOption.novaSenhaAdmin:
        return DrawerItem(
          title: 'Esqueci a senha',
          icon: Icons.lock_reset,
          onTap: () => _navigateTo(context, const NewPassAdmScreen()),
        );
      case DrawerMenuOption.novaSenhaOperador:
        return DrawerItem(
          title: 'Esqueci a senha',
          icon: Icons.password,
          onTap: () => _navigateTo(context, const NewPassOperadorScreen()),
        );
      case DrawerMenuOption.registrarFazenda:
        return DrawerItem(
          title: 'Registrar fazenda',
          icon: Icons.agriculture,
          onTap: () => _navigateTo(context, const RegisterFazendaScreen()),
        );
      case DrawerMenuOption.registrarComercio:
        return DrawerItem(
          title: 'Registrar comercio',
          icon: Icons.store,
          onTap: () => _navigateTo(context, const RegisterComercioScreen()),
        );
      case DrawerMenuOption.registrarOperador:
        return DrawerItem(
          title: 'Registrar operador',
          icon: Icons.person_add,
          onTap: () => _navigateTo(context, const RegisterOperadorScreen()),
        );
      case DrawerMenuOption.editarOperador:
        return DrawerItem(
          title: 'Editar operador',
          icon: Icons.edit,
          onTap: () => _navigateTo(context, const ViewOperadorScreen()),
        );
      case DrawerMenuOption.registrarTalhao:
        return DrawerItem(
          title: 'Registrar talhao',
          icon: Icons.grass,
          onTap: () => _navigateTo(context, const RegisterTalhaoScreen()),
        );
      case DrawerMenuOption.editarTalhao:
        return DrawerItem(
          title: 'Talhoes',
          icon: Icons.edit_location_alt,
          onTap: () => _navigateTo(context, const ViewTalhaoScreen()),
        );
      case DrawerMenuOption.registrarLote:
        return DrawerItem(
          title: 'Registrar lote',
          icon: Icons.inventory_2,
          onTap: () => _navigateTo(context, const RegisterLoteScreen()),
        );
      case DrawerMenuOption.editarLote:
        return DrawerItem(
          title: 'Lotes',
          icon: Icons.edit_note,
          onTap: () => _navigateTo(context, const ViewLoteScreen()),
        );
      case DrawerMenuOption.talhoes:
        return DrawerItem(
          title: 'Talhoes',
          icon: Icons.grass,
          onTap: () => _navigateTo(context, const ViewTalhaoOperadorScreen()),
        );
      case DrawerMenuOption.carrinho:
        return DrawerItem(
          title: 'Carrinho',
          icon: Icons.shopping_cart,
          onTap: () => _navigateTo(context, const CarrinhoScreen()),
        );
      case DrawerMenuOption.perfilOperador:
        return DrawerItem(
          title: 'Perfil do operador',
          icon: Icons.person,
          onTap: () => _navigateTo(context, const PerfilOperadorScreen()),
        );
      case DrawerMenuOption.marketplace:
        return DrawerItem(
          title: 'Marketplace',
          icon: Icons.storefront,
          onTap: () => _navigateTo(context, const MarketplaceScreen()),
        );
      case DrawerMenuOption.configuracoes:
        return DrawerItem(
          title: 'Configuracoes',
          icon: Icons.settings,
          onTap: () => _navigateTo(context, const ConfiguracoesScreen()),
        );
      case DrawerMenuOption.logout:
        return DrawerItem(
          title: 'Sair',
          icon: Icons.logout,
          onTap: () {
            SessionService.clearSession().then((_) {
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginComercioScreen()),
                (Route<dynamic> route) => false,
              );
            });
          },
        );
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
