import 'package:agrohub_app/constants.dart';
import 'package:agrohub_app/pages/edit/operador.dart';
import 'package:agrohub_app/pages/registro/operador.dart';
import 'package:agrohub_app/pages/view/operador.dart';
import 'package:flutter/material.dart';

import 'package:agrohub_app/components/button.dart'; // <- Import do teu botão adicionado
import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/login/adm.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/pages/login/operador.dart';
import 'package:agrohub_app/pages/edit/pass_adm.dart';
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/pages/registro/comercio.dart';
import 'package:agrohub_app/pages/registro/fazenda.dart';

enum DrawerMenuOption {
  operador,
  administrador,
  homeAdmin,
  listaOperadores,
  novaSenhaAdmin,
  novaSenhaOperador,
  registrarFazenda,
  registrarComercio,
  registrarOperador,
  editarOperador,
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

    return Drawer(
      backgroundColor: backgroundColor ?? componentSurfaceColor,
      // Usamos Column para poder colocar itens no rodapé
      child: Column(
        children: [
          // Expanded empurra o botão lá para o fundo
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
                // Renderiza os itens do menu normal
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
          ),

          // O teu Botão de Sair fixo no rodapé
          const Divider(height: 1, color: Colors.grey), // Linha de separação
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: ButtonComponent(
                label: 'Sair', // Fica melhor em Português
                borderRadius: 10,
                width: 200, // Estica para ocupar toda a largura
                height: 50,
                onPressed: () {
                  // Navegação com segurança (limpa histórico)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginComercioScreen()),
                    (Route<dynamic> route) => false,
                  );
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
        // Filtro de segurança: remove o logout da lista para não duplicar com o botão do rodapé
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
          onTap: () {
            _navigateTo(context, const LoginOperadorScreen());
            debugPrint('Navegar para Operador');
          },
        );

      case DrawerMenuOption.administrador:
        return DrawerItem(
          title: 'Administrador',
          icon: Icons.admin_panel_settings,
          onTap: () {
            _navigateTo(context, const LoginAdmScreen());
            debugPrint('Navegar para Administrador');
          },
        );
      case DrawerMenuOption.homeAdmin:
        return DrawerItem(
          title: 'Home Admin',
          icon: Icons.space_dashboard,
          onTap: () {
            _navigateTo(context, const HomeAdmScreen());
            debugPrint('Navegar para Home Admin');
          },
        );
      case DrawerMenuOption.listaOperadores:
        return DrawerItem(
          title: 'Lista de operadores',
          icon: Icons.list,
          onTap: () {
            _navigateTo(context, const ViewOperadorScreen());
          },
        );
      case DrawerMenuOption.novaSenhaAdmin:
        return DrawerItem(
          title: 'Esqueci a senha',
          icon: Icons.lock_reset,
          onTap: () {
            _navigateTo(context, const NewPassAdmScreen());
            debugPrint('Navegar para nova senha admin');
          },
        );
      case DrawerMenuOption.novaSenhaOperador:
        return DrawerItem(
          title: 'Esqueci a senha',
          icon: Icons.password,
          onTap: () {
            _navigateTo(context, const NewPassOperadorScreen());
            debugPrint('Navegar para nova senha operador');
          },
        );
      case DrawerMenuOption.registrarFazenda:
        return DrawerItem(
          title: 'Registrar fazenda',
          icon: Icons.agriculture,
          onTap: () {
            _navigateTo(context, const RegisterFazendaScreen());
          },
        );
      case DrawerMenuOption.registrarComercio:
        return DrawerItem(
          title: 'Registrar comércio',
          icon: Icons.store,
          onTap: () {
            _navigateTo(context, const RegisterComercioScreen());
          },
        );
      case DrawerMenuOption.registrarOperador:
        return DrawerItem(
          title: 'Registrar operador',
          icon: Icons.person_add,
          onTap: () {
            _navigateTo(context, const RegisterOperadorScreen());
          },
        );
      case DrawerMenuOption.editarOperador:
        return DrawerItem(
          title: 'Editar operador',
          icon: Icons.edit,
          onTap: () {
            _navigateTo(context, const EditOperadorScreen());
          },
        );
      case DrawerMenuOption.configuracoes:
        return DrawerItem(
          title: 'Configurações',
          icon: Icons.settings,
          onTap: () {
            Navigator.pop(context); // Aqui apenas fechamos o menu
            debugPrint('Navegar para Configurações');
          },
        );
      case DrawerMenuOption.logout:
        return DrawerItem(
          title: 'Sair',
          icon: Icons.logout,
          onTap: () {
            // Mantivemos esta opção configurada de forma segura caso precises de usar em outro contexto
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginComercioScreen()),
              (Route<dynamic> route) => false,
            );
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
