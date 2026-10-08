import 'package:agrohub_app/components/profile_avatar.dart';
import 'package:agrohub_app/constants.dart';
import 'package:agrohub_app/pages/login/adm.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/pages/login/operador.dart';
import 'package:agrohub_app/pages/edit/pass_adm.dart';
import 'package:agrohub_app/pages/edit/empresa.dart';
import 'package:agrohub_app/pages/edit/pass_operador.dart';
import 'package:agrohub_app/pages/registro/comercio.dart';
import 'package:agrohub_app/pages/registro/fazenda.dart';
import 'package:agrohub_app/pages/registro/lote.dart';
import 'package:agrohub_app/pages/registro/operador.dart';
import 'package:agrohub_app/pages/registro/talhao.dart';
import 'package:agrohub_app/pages/view/configuracoes.dart';
import 'package:agrohub_app/pages/view/configuracoes_adm.dart';
import 'package:agrohub_app/pages/view/configuracoes_operador.dart';
import 'package:agrohub_app/pages/view/finance_screen.dart';
import 'package:agrohub_app/pages/view/lotes.dart';
import 'package:agrohub_app/pages/view/marketplace.dart';
import 'package:agrohub_app/pages/view/operador.dart';
import 'package:agrohub_app/pages/view/perfil_adm.dart';
import 'package:agrohub_app/pages/view/perfil_operador.dart';
import 'package:agrohub_app/pages/view/talhoes.dart';
import 'package:agrohub_app/pages/view/talhoes_operador.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

enum DrawerMenuOption {
  operador, inicio, administrador, homeAdmin, homeOperador, listaOperadores,
  novaSenhaAdmin, novaSenhaOperador, registrarFazenda, registrarComercio,
  registrarOperador, editarOperador, registrarTalhao, editarTalhao, registrarLote,
  editarLote, talhoes, carrinho, perfilOperador, perfilAdm, financeiro, marketplace,
  configuracoes, configuracoesAdm, configuracoesOperador, logout,
  editarEmpresa, lotesOperador,
}

class DrawerItem {
  const DrawerItem({required this.title, required this.icon, required this.onTap,
    this.iconColor, this.textColor});
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
}

class DrawerMenuComponent extends StatefulWidget {
  const DrawerMenuComponent({
    super.key, this.headerTitle, this.headerSubtitle,
    this.headerIcon = Icons.account_circle, this.headerColor = componentPrimaryColor,
    this.backgroundColor, this.items, this.visibleOptions,
    this.headerLeading,
    this.hiddenOptions = const {},
  });
  final String? headerTitle;
  final String? headerSubtitle;
  final IconData headerIcon;
  final Color headerColor;
  final Color? backgroundColor;
  final Widget? headerLeading;
  final List<DrawerItem>? items;
  final Set<DrawerMenuOption>? visibleOptions;
  final Set<DrawerMenuOption> hiddenOptions;

  @override
  State<DrawerMenuComponent> createState() => _DrawerMenuComponentState();
}

class _DrawerMenuComponentState extends State<DrawerMenuComponent> {
  final Future<SessionData?> _session = SessionService.loadSession();

  Set<DrawerMenuOption> _options(SessionData? session) {
    if (session?.isAdmin ?? false) {
      return {
        DrawerMenuOption.homeAdmin, DrawerMenuOption.financeiro,
        DrawerMenuOption.marketplace, DrawerMenuOption.editarLote,
        DrawerMenuOption.editarTalhao, DrawerMenuOption.listaOperadores,
        DrawerMenuOption.editarEmpresa, DrawerMenuOption.perfilAdm, DrawerMenuOption.configuracoesAdm,
      };
    }
    if (session?.isOperator ?? false) {
      return {
        DrawerMenuOption.homeOperador, DrawerMenuOption.marketplace,
        DrawerMenuOption.editarLote, DrawerMenuOption.talhoes,
        DrawerMenuOption.perfilOperador, DrawerMenuOption.configuracoesOperador,
      };
    }
    return widget.visibleOptions ?? {
      if (session?.isCompanySession ?? false) ...[
        DrawerMenuOption.operador, DrawerMenuOption.administrador,
      ] else DrawerMenuOption.inicio,
      DrawerMenuOption.configuracoes,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: widget.backgroundColor ?? colors.surface,
      child: FutureBuilder<SessionData?>(
        future: _session,
        builder: (context, snapshot) {
          final session = snapshot.data;
          final authenticated = session != null && (session.isAdmin || session.isOperator);
          final items = widget.items ?? _options(session)
              .where((item) => item != DrawerMenuOption.logout && item != DrawerMenuOption.carrinho)
              .where((item) => !widget.hiddenOptions.contains(item))
              .map((option) => _item(context, option, session)).toList();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 28, 24, 24),
                      color: colors.primaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.headerLeading != null) widget.headerLeading!
                          else if (authenticated) const SessionProfileAvatar(radius: 30)
                          else Icon(widget.headerIcon, size: 48, color: colors.onPrimaryContainer),
                          const SizedBox(height: 12),
                          Text(authenticated ? (session.isAdmin ? 'Administrador' : 'Operador')
                              : widget.headerTitle ?? 'AgroHub',
                              style: TextStyle(color: colors.onPrimaryContainer,
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          if (session?.displayName != null || widget.headerSubtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(widget.headerSubtitle ?? session!.displayName!,
                                style: TextStyle(color: colors.onPrimaryContainer)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                      leading: Icon(item.icon, color: item.iconColor ?? colors.onSurfaceVariant),
                      title: Text(item.title, style: TextStyle(color: item.textColor ?? colors.onSurface,
                          fontWeight: FontWeight.w600)),
                      onTap: item.onTap,
                    )),
                  ],
                ),
              ),
              if (session != null) ...[
                const Divider(height: 1),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair da conta'),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _logout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginComercioScreen()), (_) => false);
  }

  DrawerItem _item(BuildContext context, DrawerMenuOption option, SessionData? session) {
    DrawerItem route(String title, IconData icon, Widget screen) => DrawerItem(
      title: title, icon: icon, onTap: () => _navigateTo(context, screen),
    );
    switch (option) {
      case DrawerMenuOption.inicio:
      case DrawerMenuOption.homeAdmin:
      case DrawerMenuOption.homeOperador:
        return DrawerItem(title: 'Início', icon: Icons.dashboard_outlined,
            onTap: () => FlowNavigation.goToRoot(context));
      case DrawerMenuOption.operador:
        return route('Entrar como operador', Icons.engineering_outlined, const LoginOperadorScreen());
      case DrawerMenuOption.administrador:
        return route('Entrar como administrador', Icons.admin_panel_settings_outlined, const LoginAdmScreen());
      case DrawerMenuOption.listaOperadores:
      case DrawerMenuOption.editarOperador:
        return route('Operadores', Icons.groups_outlined, const ViewOperadorScreen());
      case DrawerMenuOption.novaSenhaAdmin:
        return route('Alterar senha', Icons.lock_reset, const NewPassAdmScreen());
      case DrawerMenuOption.novaSenhaOperador:
        return route('Alterar senha', Icons.lock_reset, const NewPassOperadorScreen());
      case DrawerMenuOption.registrarFazenda:
        return route('Cadastrar fazenda', Icons.agriculture, const RegisterFazendaScreen());
      case DrawerMenuOption.registrarComercio:
        return route('Cadastrar comércio', Icons.storefront, const RegisterComercioScreen());
      case DrawerMenuOption.registrarOperador:
        return route('Cadastrar operador', Icons.person_add_outlined, const RegisterOperadorScreen());
      case DrawerMenuOption.registrarTalhao:
        return route('Cadastrar talhão', Icons.add_location_alt_outlined, const RegisterTalhaoScreen());
      case DrawerMenuOption.editarTalhao:
        return route('Talhões', Icons.grass, const ViewTalhaoScreen());
      case DrawerMenuOption.registrarLote:
        return route('Cadastrar lote', Icons.add_box_outlined, const RegisterLoteScreen());
      case DrawerMenuOption.editarLote:
      case DrawerMenuOption.lotesOperador:
        return route('Lotes', Icons.inventory_2_outlined, const ViewLoteScreen());
      case DrawerMenuOption.talhoes:
        return route('Talhões', Icons.grass, const ViewTalhaoOperadorScreen());
      case DrawerMenuOption.carrinho:
      case DrawerMenuOption.marketplace:
        return route('Estoque', Icons.storefront_outlined, const MarketplaceScreen());
      case DrawerMenuOption.perfilAdm:
        return route('Meu perfil', Icons.account_circle_outlined, const PerfilAdmScreen());
      case DrawerMenuOption.perfilOperador:
        return route('Meu perfil', Icons.account_circle_outlined, const PerfilOperadorScreen());
      case DrawerMenuOption.financeiro:
        return route('Financeiro', Icons.insights, const FinanceScreen());
      case DrawerMenuOption.editarEmpresa:
        return route('Dados da empresa', Icons.business_outlined, const CompanyEditLoader());
      case DrawerMenuOption.configuracoes:
      case DrawerMenuOption.configuracoesAdm:
      case DrawerMenuOption.configuracoesOperador:
        return route('Configurações', Icons.settings_outlined,
            (session?.isAdmin ?? false) ? const ConfiguracoesAdmScreen()
                : (session?.isOperator ?? false) ? const ConfiguracoesOperadorScreen()
                : const ConfiguracoesScreen());
      case DrawerMenuOption.logout:
        return DrawerItem(title: 'Sair', icon: Icons.logout, onTap: _logout);
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
