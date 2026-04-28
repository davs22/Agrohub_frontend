import 'package:flutter/material.dart';

import 'package:agrohub_app/components/component_colors.dart';

class PopupComponent {
  const PopupComponent({
    required this.title,
    required this.content,
    this.closeText,
    this.controll,
    this.onClick,
  });

  final String title;
  final String content;
  final String? closeText;
  final TextEditingController? controll;
  final VoidCallback? onClick;

  static void alert(
    BuildContext context, {
    required String title,
    required String content,
    String? closeText,
    TextEditingController? controll,
    VoidCallback? onClick,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: componentSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentBorderRadius),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: componentTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              color: componentTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: componentTextColor),
              onPressed: () {
                Navigator.of(context).pop();
                onClick?.call();
              },
              child: Text(
                closeText ?? 'Fechar',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  static void input(
    BuildContext context, {
    required String title,
    required String content,
    String? label,
    String? hint,
    Color? color,
    TextEditingController? controll,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: componentSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentBorderRadius),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: componentTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                content,
                style: const TextStyle(
                  color: componentTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controll,
                style: const TextStyle(
                  color: componentTextColor,
                  fontSize: componentFieldFontSize,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: label ?? 'Digite aqui.',
                  hintText: hint ?? '',
                  labelStyle: TextStyle(color: color ?? componentAccentColor),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color ?? componentAccentColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
