import 'package:agrohub_app/pages/registro/register_operador_screen.dart';
import 'package:flutter/material.dart';

import 'package:agrohub_app/components/component_colors.dart';
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/login/login_adm_screen.dart';
import 'package:agrohub_app/pages/login/login_comercio_screen.dart';
import 'package:agrohub_app/pages/login/login_operador_screen.dart';
import 'package:agrohub_app/pages/registro/new_pass_adm_screen.dart';
import 'package:agrohub_app/pages/registro/new_pass_operador_screen.dart';
import 'package:agrohub_app/pages/registro/register_comercio_screen.dart';
import 'package:agrohub_app/pages/registro/register_fazenda_screen.dart';

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
  });

  final String? headerTitle;
  final String? headerSubtitle;
  final IconData headerIcon;
  final Color headerColor;
  final Color? backgroundColor;
  final List<DrawerItem>? items;

  @override
  Widget build(BuildContext context) {
    final resolvedItems = items ?? _buildDefaultItems(context);

    return Drawer(
      backgroundColor: backgroundColor ?? componentSurfaceColor,
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
                color: item.iconColor ?? componentTextColor,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  color: item.textColor ?? componentTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: item.onTap,
            ),
          ),
        ],
      ),
    );
  }

  List<DrawerItem> _buildDefaultItems(BuildContext context) {
    return [
      DrawerItem(
        title: 'Operador',
        icon: Icons.manage_accounts,
        onTap: () {
          _navigateTo(context, const LoginOperadorScreen());
          debugPrint('Navegar para Operador');
        },
      ),
      DrawerItem(
        title: 'Administrador',
        icon: Icons.admin_panel_settings,
        onTap: () {
          _navigateTo(context, const LoginAdmScreen());
          debugPrint('Navegar para Administrador');
        },
      ),
      DrawerItem(
        title: 'homeAdmin',
        icon: Icons.space_dashboard,
        onTap: () {
          _navigateTo(context, const HomeAdmScreen());
          debugPrint('Navegar para Administrador');
        },
      ),
      DrawerItem(
        title: 'nova senha admin',
        icon: Icons.lock_reset,
        onTap: () {
          _navigateTo(context, const NewPassAdmScreen());
          debugPrint('Navegar para nova senha admin');
        },
      ),
      DrawerItem(
        title: 'Nova senha operador',
        icon: Icons.password,
        onTap: () {
          _navigateTo(context, const NewPassOperadorScreen());
          debugPrint('Navegar para nova senha operador');
        },
      ),
      DrawerItem(
        title: 'Registrar fazenda',
        icon: Icons.agriculture,
        onTap: () {
          _navigateTo(context, const RegisterFazendaScreen());
        },
      ),
      DrawerItem(
        title: 'Registrar comercio',
        icon: Icons.store,
        onTap: () {
          _navigateTo(context, const RegisterComercioScreen());
        },
      ),
      DrawerItem(
        title: 'Registrar operador',
        icon: Icons.person_add,
        onTap: () {
          _navigateTo(context, const RegisterOperadorScreen());
        },
      ),
      DrawerItem(
        title: 'Configuracoes',
        icon: Icons.settings,
        onTap: () {
          Navigator.pop(context);
          debugPrint('Navegar para Configuracoes');
        },
      ),
      DrawerItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () {
          _navigateTo(context, const LoginComercioScreen());
        },
      ),
    ];
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
