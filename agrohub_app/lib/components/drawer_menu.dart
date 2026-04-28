import 'package:flutter/material.dart';

import 'package:agrohub_app/components/component_colors.dart';

class DrawerItem {
  const DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
}

class DrawerMenuComponent extends StatelessWidget {
  const DrawerMenuComponent({
    super.key,
    this.headerTitle,
    this.headerSubtitle,
    this.headerIcon = Icons.account_circle,
    this.headerColor = componentPrimaryColor,
    this.backgroundColor,
    required this.items,
  });

  final String? headerTitle;
  final String? headerSubtitle;
  final IconData headerIcon;
  final Color headerColor;
  final Color? backgroundColor;
  final List<DrawerItem> items;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor ?? componentSurfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: headerColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(headerIcon, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                if (headerTitle != null)
                  Text(
                    headerTitle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (headerSubtitle != null)
                  Text(
                    headerSubtitle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          ...items.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 2,
              ),
              leading: Icon(
                item.icon,
                color: item.iconColor ?? componentTextColor,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  color: item.textColor ?? componentTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: item.onTap,
            ),
          ),
        ],
      ),
    );
  }
}
