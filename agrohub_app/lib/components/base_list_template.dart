import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';
import 'package:agrohub_app/utils/flow_navigation.dart';
import 'package:agrohub_app/utils/responsive_layout.dart';
import 'package:flutter/material.dart';

class BaseListTemplate extends StatelessWidget {
  final String title;
  final String headerDrawerTitle;
  final Set<DrawerMenuOption> visibleOptions;
  final List<Widget> fields;
  final bool isLoading;
  final VoidCallback onSubmit;

  const BaseListTemplate({
    super.key,
    required this.title,
    required this.headerDrawerTitle,
    required this.visibleOptions,
    required this.fields,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return FlowBackGuard(
      child: Scaffold(
        appBar: AppBarComponent(
          title: 'AgroHub',
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
          ],
        ),
        endDrawer: DrawerMenuComponent(
          headerTitle: headerDrawerTitle,
          visibleOptions: visibleOptions,
        ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = ResponsiveLayout.contentMaxWidth(
              constraints.maxWidth,
              mobile: 450,
              tablet: 700,
              desktop: 820,
            );
            final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(constraints.maxWidth);
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                  ),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextComponent(
                                text: title,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ...fields,
                          const SizedBox(height: 40),
                          isLoading
                              ? const CircularProgressIndicator(color: Colors.green)
                              : ButtonComponent(
                                  label: 'Atualizar',
                                  height: 40,
                                  fontSize: 16,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  isDisabled: isLoading,
                                  onPressed: onSubmit,
                                  borderColor: const Color.fromARGB(255, 76, 175, 80),
                                  backgroundColor: const Color.fromARGB(255, 76, 175, 80),
                                  borderRadius: 4,
                                  width: double.infinity,
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
