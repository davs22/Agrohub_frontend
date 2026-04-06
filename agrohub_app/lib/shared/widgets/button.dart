import 'package:flutter/material.dart';

enum ButtonType { elevated, outlined, text }

class ButtonComponent extends StatelessWidget {
  const ButtonComponent({super.key, required this.label, this.onPressed, this.isDisabled = false, this.icon, this.type = ButtonType.elevated, this.backgroundColor, this.textColor, this.borderColor, this.disabledBackgroundColor, this.disabledTextColor, this.fontSize, this.textAlign = TextAlign.center, this.padding, this.iconSpacing = 8.0, this.borderRadius});

  final String label;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final IconData? icon;
  final ButtonType type;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double? fontSize;
  final TextAlign textAlign;
  final EdgeInsets? padding;
  final double iconSpacing;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isDisabled ? null : onPressed;

    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: (fontSize ?? 14.0) + 4, color: _determineTextColor(context)),
          SizedBox(width: iconSpacing),
        ],
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(fontSize: fontSize, color: _determineTextColor(context)),
        ),
      ],
    );

    final ButtonStyle commonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      side: type == ButtonType.outlined && borderColor != null ? BorderSide(color: borderColor!) : null,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledTextColor,
      shape: borderRadius != null ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius!)) : null,
      padding: padding,
    );

    switch (type) {
      case ButtonType.outlined:
        return OutlinedButton(onPressed: action, style: commonStyle, child: buttonChild);
      case ButtonType.text:
        return TextButton(onPressed: action, style: commonStyle, child: buttonChild);
      case ButtonType.elevated:
      default:
        return ElevatedButton(onPressed: action, style: commonStyle, child: buttonChild);
    }
  }

  Color? _determineTextColor(BuildContext context) {
    if (isDisabled || onPressed == null) {
      return disabledTextColor ?? (type == ButtonType.elevated ? Theme.of(context).disabledColor : null);
    }
    return textColor ?? (type != ButtonType.elevated ? Theme.of(context).primaryColor : null);
  }
}