import 'package:agrohub_app/constants.dart';
import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final VoidCallback? action = isDisabled ? null : onPressed;
    final Color resolvedTextColor = _determineTextColor();
    final double resolvedFontSize = _resolveFontSize();
    final EdgeInsets resolvedPadding = _resolvePadding();

    final Widget buttonChild = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: resolvedFontSize + 2,
              color: resolvedTextColor,
            ),
            SizedBox(width: iconSpacing),
          ],
          Text(
            label,
            textAlign: textAlign,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontSize: resolvedFontSize,
              color: resolvedTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final ButtonStyle commonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(width ?? 210, height ?? componentButtonHeight),
      ),
      padding: WidgetStatePropertyAll(
        padding ?? resolvedPadding,
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBackgroundColor ?? const Color(0xFFBDBDBD);
        }
        if (type == ButtonType.elevated) {
          return backgroundColor ?? colorScheme.primary;
        }
        if (type == ButtonType.text) {
          return Colors.transparent;
        }
        return backgroundColor ?? colorScheme.surface;
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

  double _resolveFontSize() {
    if (fontSize != null) {
      return fontSize!;
    }

    final resolvedHeight = height ?? componentButtonHeight;
    if (resolvedHeight <= 40) {
      return 14;
    }
    if (resolvedHeight <= 46) {
      return 15;
    }
    return componentButtonFontSize;
  }

  EdgeInsets _resolvePadding() {
    if (padding != null) {
      return padding!;
    }

    final resolvedHeight = height ?? componentButtonHeight;
    if (resolvedHeight <= 40) {
      return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
    }
    if (resolvedHeight <= 46) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 7);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  }
}
