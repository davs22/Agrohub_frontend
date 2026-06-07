import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:agrohub_app/components/app_bar.dart';
import 'package:agrohub_app/components/button.dart';
import 'package:agrohub_app/components/drawer_menu.dart';
import 'package:agrohub_app/components/text.dart';

class BaseLoginTemplate extends StatelessWidget {
  final String title;
  final String svgPath;
  final String headerDrawerTitle;
  final Set<DrawerMenuOption> visibleOptions;
  final List<Widget> fields;
  final bool isLoading;
  final VoidCallback onSubmit;
  final Widget? footerWidget;

  const BaseLoginTemplate({
    super.key,
    required this.title,
    required this.svgPath,
    required this.headerDrawerTitle,
    required this.visibleOptions,
    required this.fields,
    required this.isLoading,
    required this.onSubmit,
    this.footerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            svgPath,
                            width: 110,
                            height: 110,
                          ),
                        ),
                        const SizedBox(height: 60),
                        TextComponent(
                          text: title,
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          aligment: TextAlign.left,
                        ),
                        const SizedBox(height: 12),
                        ...fields,
                        const SizedBox(height: 60),
                        Center(
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.green)
                              : ButtonComponent(
                                  label: 'Entrar',
                                  borderRadius: 10,
                                  width: 150,
                                  height: 50,
                                  isDisabled: isLoading,
                                  onPressed: onSubmit,
                                ),
                        ),
                        if (footerWidget != null) ...[
                          const SizedBox(height: 20),
                          Center(child: footerWidget!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}