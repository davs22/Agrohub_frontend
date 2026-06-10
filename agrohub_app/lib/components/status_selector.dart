import 'package:agrohub_app/components/component_colors.dart';
import 'package:agrohub_app/constants.dart';
import 'package:flutter/material.dart';

class StatusSelectorComponent extends StatelessWidget {
  const StatusSelectorComponent({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: componentSurfaceColor,
        border: Border.all(color: componentBorderColor),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [componentShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: componentTextColor),
          const SizedBox(width: 12),
          Text(
            isActive ? 'Ativo' : 'Inativo',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: componentTextColor,
            ),
          ),
          const Spacer(),
          Switch(
            value: isActive,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
