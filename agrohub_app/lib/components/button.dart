import 'package:flutter/material.dart';

import 'package:agrohub_app/components/component_colors.dart';

enum ButtonType { elevated, outlined, text }

class ButtonComponent extends StatelessWidget {
  const ButtonComponent({
    super.key,
    required this.label,
    this.onPressed,
    this.isDisabled = false,
    this.icon,
    this.type = ButtonType.elevated,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.fontSize,
    this.textAlign = TextAlign.center,
    this.padding,
    this.iconSpacing = 8.0,
    this.borderRadius,
    this.width,
    this.height,
  });

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
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isDisabled ? null : onPressed;
    final Color resolvedTextColor = _determineTextColor();

    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: (fontSize ?? componentButtonFontSize) + 2,
            color: resolvedTextColor,
          ),
          SizedBox(width: iconSpacing),
        ],
        Text(
          label,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize ?? componentButtonFontSize,
            color: resolvedTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final ButtonStyle commonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(width ?? 210, height ?? componentButtonHeight),
      ),
      padding: WidgetStatePropertyAll(
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBackgroundColor ?? const Color(0xFFBDBDBD);
        }
        if (type == ButtonType.elevated) {
          return backgroundColor ?? componentPrimaryColor;
        }
        if (type == ButtonType.text) {
          return Colors.transparent;
        }
        return componentSurfaceColor;
      }),
      foregroundColor: WidgetStatePropertyAll(resolvedTextColor),
      elevation: const WidgetStatePropertyAll(0),
      side: WidgetStatePropertyAll(
        type == ButtonType.outlined
            ? BorderSide(color: borderColor ?? componentTextColor, width: 1)
            : BorderSide.none,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? componentBorderRadius,
          ),
        ),
      ),
    );

    final Widget builtButton;
    switch (type) {
      case ButtonType.outlined:
        builtButton = OutlinedButton(
          onPressed: action,
          style: commonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        builtButton = TextButton(
          onPressed: action,
          style: commonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.elevated:
        builtButton = ElevatedButton(
          onPressed: action,
          style: commonStyle,
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: builtButton,
    );
  }

  Color _determineTextColor() {
    if (isDisabled || onPressed == null) {
      return disabledTextColor ?? componentTextColor.withAlpha(153);
    }
    return textColor ?? componentTextColor;
  }
}
