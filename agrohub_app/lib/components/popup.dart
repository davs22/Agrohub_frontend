import 'package:agrohub_app/default.config.dart';
import 'package:flutter/material.dart';

class PopupComponent {
  const PopupComponent({required this.title, required this.content, this.closeText, this.controll, this.onClick});
  final String title;
  final String content;
  final String? closeText;
  final TextEditingController? controll;
  final VoidCallback? onClick;

  static void alert(BuildContext context, {required String title, required String content, String? closeText, TextEditingController? controll, VoidCallback? onClick}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(closeText ?? "Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
                onClick!();
              },
            ),
          ],
        );
      },
    );
  }

  static void input(BuildContext context,
      {required String title,
      required String content,
      String? label,
      String? hint,
      Color? color,
      TextEditingController? controll}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextField(
              controller: controll,
              decoration: InputDecoration(
                labelText: label ?? "Digite aqui.",
                hintText: hint ?? "",
                labelStyle: TextStyle(color: color ?? colorItems),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 19, 88, 144))),
              ),
            ),
          ],
        );
      },
    );
  }
}