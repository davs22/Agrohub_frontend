import 'package:agrohub_app/pages/home_adm_screen.dart';
import 'package:agrohub_app/pages/home_operador_screen.dart';
import 'package:agrohub_app/pages/login/comercio.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

class AppEntryGate extends StatelessWidget {
  const AppEntryGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionData?>(
      future: SessionService.loadSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.data;
        if (session != null) {
          if (session.role == 'OPERADOR') {
            return const HomeOperadorScreen();
          }

          return const HomeAdmScreen();
        }

        return const LoginComercioScreen();
      },
    );
  }
}
