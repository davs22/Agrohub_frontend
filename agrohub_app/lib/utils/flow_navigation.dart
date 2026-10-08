import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/home_operador_screen.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/pages/login/operador.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

class FlowNavigation {
  static const String adminHomeStage = 'ADMIN_HOME';
  static const String operatorHomeStage = 'OPERATOR_HOME';
  static const String operatorLoginStage = 'OPERATOR_LOGIN';

  static Widget rootScreenForSession(SessionData? session) {
    if (session?.isOperator ?? false) {
      return const HomeOperadorScreen();
    }
    if (session?.isAdmin ?? false) {
      return const HomeAdmScreen();
    }
    if (session?.isCompanySession ?? false) {
      return const LoginOperadorScreen();
    }

    return const LoginComercioScreen();
  }

  static Future<void> goToRoot(BuildContext context) async {
    final session = await SessionService.loadSession();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => rootScreenForSession(session)),
      (route) => false,
    );
  }
}

class FlowBackGuard extends StatelessWidget {
  const FlowBackGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          FlowNavigation.goToRoot(context);
        }
      },
      child: child,
    );
  }
}
