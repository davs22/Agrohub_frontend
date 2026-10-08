import 'package:agrohub_app/services/session_service.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  final Future<SessionData?> _session = SessionService.loadSession();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionData?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return FlowNavigation.rootScreenForSession(snapshot.data);
      },
    );
  }
}
