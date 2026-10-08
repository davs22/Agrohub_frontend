import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/session_drawer.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:flutter/material.dart';

class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    required this.headerDrawerTitle,
    required this.visibleOptions,
    required this.fields,
    required this.isLoading,
    required this.onSubmit,
    required this.submitLabel,
  });

  final String title;
  final String headerDrawerTitle;
  final Set<DrawerMenuOption> visibleOptions;
  final List<Widget> fields;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return FlowBackGuard(
      child: Scaffold(
        appBar: AppBarComponent(
          title: 'AgroHub',
          automaticallyImplyLeading: false,
          actions: [
            Builder(builder: (context) => IconButton(
              tooltip: 'Abrir menu',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu),
            )),
          ],
        ),
        endDrawer: const SessionAwareDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ...fields,
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: isLoading ? null : onSubmit,
                      child: isLoading
                          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(submitLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
