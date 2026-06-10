import 'package:agrohub_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agrohub_app/components/component_colors.dart';

class InputComponent extends StatefulWidget {
  const InputComponent({
    super.key,
    this.borderRadius,
    this.hintColor,
    this.label,
    this.hint,
    this.ephemeral,
    this.controll,
    this.eventChange,
    this.borderColor,
    this.lengthText,
    this.counter,
    this.typeInput,
    this.emoji,
    this.width,
    this.height,
    this.suffixIcon,
    this.showVisibilityToggle,
    this.errorText,
    this.inputFormatters,
    this.readOnly,
    this.onTap,
  });

  final double? borderRadius;
  final Color? hintColor;
  final IconData? emoji;
  final double? width;
  final double? height;
  final String? label;
  final String? hint;
  final bool? ephemeral;
  final TextEditingController? controll;
  final ValueChanged<String>? eventChange;
  final Color? borderColor;
  final int? lengthText;
  final bool? counter;
  final TextInputType? typeInput;
  final IconData? suffixIcon;
  final bool? showVisibilityToggle;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final bool? readOnly;
  final VoidCallback? onTap;

  @override
  State<InputComponent> createState() => _InputComponentState();
}

class _InputComponentState extends State<InputComponent> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.ephemeral ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final borderColor = widget.borderColor ?? colorScheme.outlineVariant;
    final hintColor = widget.hintColor ?? textColor.withValues(alpha: 0.55);

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((widget.label ?? '').isNotEmpty) ...[
            Text(
              widget.label!,
              style: TextStyle(
                color: textColor,
                fontSize: componentLabelFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Container(
            height: widget.height ?? componentInputHeight,
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? componentBorderRadius,
              ),
              boxShadow: const [componentShadow],
            ),
            child: TextField(
              maxLength: widget.lengthText,
              obscureText: _obscureText,
              controller: widget.controll,
              keyboardType: widget.typeInput,
              readOnly: widget.readOnly ?? false,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: widget.inputFormatters,
              style: TextStyle(
                color: textColor,
                fontSize: componentFieldFontSize,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              decoration: InputDecoration(
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
                prefixIcon: widget.emoji == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Icon(
                          widget.emoji,
                          size: 22,
                          color: textColor,
                        ),
                      ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 52,
                  minHeight: widget.height ?? componentInputHeight,
                ),
                suffixIcon: _buildSuffixIcon(),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 52,
                  minHeight: widget.height ?? componentInputHeight,
                ),
                hintText: widget.hint ?? "",
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: componentFieldFontSize,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
                counterText: widget.counter == true && widget.lengthText != null
                    ? '${widget.controll?.text.length ?? 0}/${widget.lengthText}'
                    : "",
              ),
              onChanged: widget.eventChange,
              onTap: widget.onTap,
            ),
          ),
          if ((widget.errorText ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    final textColor = Theme.of(context).colorScheme.onSurface;
    if (widget.showVisibilityToggle ?? (widget.ephemeral ?? false)) {
      return IconButton(
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: textColor,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(widget.suffixIcon, color: textColor),
      );
    }

    return null;
  }
}
