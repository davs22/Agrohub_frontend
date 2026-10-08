import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/profile_avatar.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

class SessionAwareDrawer extends StatelessWidget {
  const SessionAwareDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionData?>(
      future: SessionService.loadSession(),
      builder: (context, snapshot) {
        final session = snapshot.data;
        if (session?.isAdmin ?? false) {
          return DrawerMenuComponent(
            headerTitle: session?.displayName ?? 'Administrador',
            headerSubtitle: session?.role == 'FAZENDA' ? 'Fazenda' : 'Comércio',
            headerIcon: Icons.admin_panel_settings,
            headerLeading: const SessionProfileAvatar(radius: 28),
            visibleOptions: DrawerMenus.admin,
          );
        }
        if (session?.isOperator ?? false) {
          return DrawerMenuComponent(
            headerTitle: session?.displayName ?? 'Operador',
            headerSubtitle: 'Equipe de campo',
            headerIcon: Icons.engineering,
            headerLeading: const SessionProfileAvatar(radius: 28),
            visibleOptions: DrawerMenus.operator,
          );
        }
        return const DrawerMenuComponent(
          headerTitle: 'AgroHub',
          headerIcon: Icons.agriculture,
          visibleOptions: DrawerMenus.guest,
        );
      },
    );
  }
}

abstract final class DrawerMenus {
  static const admin = {
    DrawerMenuOption.homeAdmin,
    DrawerMenuOption.listaOperadores,
    DrawerMenuOption.registrarOperador,
    DrawerMenuOption.registrarTalhao,
    DrawerMenuOption.editarTalhao,
    DrawerMenuOption.registrarLote,
    DrawerMenuOption.editarLote,
    DrawerMenuOption.marketplace,
    DrawerMenuOption.financeiro,
    DrawerMenuOption.editarEmpresa,
    DrawerMenuOption.configuracoesAdm,
    DrawerMenuOption.logout,
  };

  static const operator = {
    DrawerMenuOption.homeOperador,
    DrawerMenuOption.marketplace,
    DrawerMenuOption.talhoes,
    DrawerMenuOption.lotesOperador,
    DrawerMenuOption.perfilOperador,
    DrawerMenuOption.configuracoesOperador,
    DrawerMenuOption.logout,
  };

  static const guest = {
    DrawerMenuOption.inicio,
    DrawerMenuOption.registrarFazenda,
    DrawerMenuOption.registrarComercio,
    DrawerMenuOption.configuracoes,
    DrawerMenuOption.logout,
  };
}
