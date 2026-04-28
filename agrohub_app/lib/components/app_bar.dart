import 'package:flutter/material.dart';

import 'package:agrohub_app/components/component_colors.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  const AppBarComponent({
    super.key,
    required this.title,
    this.centerTitle,
    this.actions,
    this.automaticallyImplyLeading,
    this.tabBar,
  });

  final String title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final bool? automaticallyImplyLeading;
  final PreferredSizeWidget? tabBar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: componentPrimaryColor,
      elevation: 0,
      toolbarHeight: componentAppBarHeight,
      centerTitle: centerTitle ?? false,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      iconTheme: const IconThemeData(
        color: componentTextColor,
        size: 32,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: componentTextColor,
          fontSize: componentTitleFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions ?? [],
      bottom: tabBar,
    );
  }

  @override
  Size get preferredSize {
    double height = componentAppBarHeight;
    if (tabBar != null) {
      height += tabBar!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}
