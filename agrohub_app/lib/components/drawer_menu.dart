import 'package:flutter/material.dart';

class DrawerItem {
  const DrawerItem({required this.title, required this.icon, required this.onTap, this.iconColor, this.textColor});
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
}

class DrawerMenuComponent extends StatelessWidget {
  const DrawerMenuComponent({super.key, this.headerTitle, this.headerSubtitle, this.headerIcon = Icons.account_circle, this.headerColor = Colors.green, this.backgroundColor, required this.items});

  final String? headerTitle;
  final String? headerSubtitle;
  final IconData headerIcon;
  final Color headerColor;
  final Color? backgroundColor;
  final List<DrawerItem> items;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
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
                if (headerTitle != null) Text(headerTitle!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                if (headerSubtitle != null) Text(headerSubtitle!, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon, color: item.iconColor ?? Colors.black87),
                title: Text(item.title, style: TextStyle(color: item.textColor ?? Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  item.onTap();
                },
              )),
        ],
      ),
    );
  }
}