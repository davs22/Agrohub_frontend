import 'package:agrohub_app/constants.dart';
import 'package:flutter/material.dart';

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
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentBorderRadius),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(96, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onClick?.call();
              },
              child: Text(
                closeText ?? 'Fechar',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
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
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(componentBorderRadius),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
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
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controll,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: componentFieldFontSize,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: label ?? 'Digite aqui.',
                  hintText: hint ?? '',
                  labelStyle: TextStyle(color: color ?? colorScheme.primary),
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color ?? colorScheme.primary),
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
