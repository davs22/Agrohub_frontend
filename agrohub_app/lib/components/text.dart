import 'package:agrohub_app/constants.dart';
import 'package:flutter/material.dart';

class TextComponent extends StatelessWidget {
  const TextComponent({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.aligment,
  });

  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? aligment;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? componentTextColor,
        fontSize: fontSize ?? componentLabelFontSize,
        fontWeight: fontWeight ?? FontWeight.w700,
      ),
      textAlign: aligment,
    );
  }
}
