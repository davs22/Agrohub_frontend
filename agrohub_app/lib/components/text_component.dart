import 'package:flutter/material.dart';

class TextComponent extends StatelessWidget {
  const TextComponent(
      {super.key, required this.text, this.color, this.fontSize, this.aligment});

  final String text;
  final Color? color;
  final double? fontSize;
  final TextAlign? aligment;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
      ),
      textAlign: aligment,
    );
  }
}
