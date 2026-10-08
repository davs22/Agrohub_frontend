import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputComponent extends StatefulWidget {
  const InputComponent({
    super.key, this.borderRadius, this.hintColor, this.label, this.hint,
    this.ephemeral, this.controll, this.eventChange, this.borderColor,
    this.lengthText, this.counter, this.typeInput, this.emoji, this.width,
    this.height, this.suffixIcon, this.showVisibilityToggle, this.errorText,
    this.inputFormatters, this.readOnly, this.onTap,
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
    final scheme = Theme.of(context).colorScheme;
    final toggle = widget.showVisibilityToggle ?? (widget.ephemeral ?? false);
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: TextField(
        controller: widget.controll,
        obscureText: _obscureText,
        enableSuggestions: !(widget.ephemeral ?? false),
        autocorrect: !(widget.ephemeral ?? false),
        keyboardType: widget.typeInput,
        readOnly: widget.readOnly ?? false,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.lengthText,
        style: TextStyle(color: scheme.onSurface, fontSize: 16),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: widget.label ?? widget.hint,
          hintText: widget.label == null ? null : widget.hint,
          hintStyle: TextStyle(color: widget.hintColor ?? scheme.onSurfaceVariant),
          errorText: widget.errorText,
          errorMaxLines: 3,
          counterText: widget.counter == true ? null : '',
          prefixIcon: widget.emoji == null ? null : Icon(widget.emoji),
          suffixIcon: toggle
              ? IconButton(
                  tooltip: _obscureText ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                )
              : widget.suffixIcon == null ? null : Icon(widget.suffixIcon),
        ),
        onChanged: widget.eventChange,
        onTap: widget.onTap,
      ),
    );
  }
}
