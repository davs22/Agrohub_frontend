import 'package:agrohub_app/constants.dart';
import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.primary,
      elevation: 0,
      toolbarHeight: componentAppBarHeight,
      centerTitle: centerTitle ?? false,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      iconTheme: IconThemeData(
        color: colorScheme.onPrimary,
        size: 32,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 25,
          fontWeight: FontWeight.w800,
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
