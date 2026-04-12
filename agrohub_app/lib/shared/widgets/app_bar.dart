import 'package:flutter/material.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? centerTitle;
  final List<Widget>? actions;
  final bool? automaticallyImplyLeading;
  final PreferredSizeWidget? tabBar;

  const AppBarComponent({super.key, required this.title, this.centerTitle, this.actions, this.automaticallyImplyLeading, this.tabBar});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      centerTitle: centerTitle ?? false,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions ?? [],
      bottom: tabBar,
    );
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (tabBar != null) {
      height += tabBar!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}
