import 'package:agrohub_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputComponent extends StatelessWidget {
  const InputComponent({super.key, this.label, this.hint, this.ephemeral, this.controll, this.eventChange, this.borderColor, this.lengthText, this.counter, this.typeInput, required this.emoji, required this.width, required this.height});
  final IconData emoji;
  final double width;
  final double height;
  final String? label;
  final String? hint;
  final bool? ephemeral;
  final TextEditingController? controll;
  final dynamic eventChange;
  final Color? borderColor;
  final int? lengthText;
  final bool? counter;
  final TextInputType? typeInput;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        maxLength: lengthText,
        obscureText: ephemeral ?? false,
        controller: controll,
        keyboardType: typeInput,
        inputFormatters: typeInput != null ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 5),
            child: Icon(emoji, size: 30, color: colorItems),
          ),
          labelText: label ?? "",
          hintText: hint ?? "",
          labelStyle: const TextStyle(color: colorItems),
          // filled: true,
          // fillColor: colorItems,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? const Color.fromARGB(255, 19, 88, 144))
          ),
          counterText: counter == true && lengthText != null ? '${controll?.text.length}/$lengthText' : ""
        ),
        // Inserir outros eventos se nescessarios.
        onChanged: (value) => eventChange(value),
      ),
    );
  }
}
