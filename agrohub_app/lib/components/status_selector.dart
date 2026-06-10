import 'package:agrohub_app/components/component_colors.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [componentShadow],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.onSurface),
          const SizedBox(width: 12),
          Text(
            isActive ? 'Ativo' : 'Inativo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Switch(
            value: isActive,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
