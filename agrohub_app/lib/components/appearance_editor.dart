import 'package:agrohub_app/components/profile_avatar.dart';
import 'package:agrohub_app/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';

class AppearanceEditor extends StatelessWidget {
  const AppearanceEditor({super.key, required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto e avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'A escolha fica vinculada a este login e não se mistura com outras contas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ProfileAvatar(appearance: model.appearance, radius: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: model.saving ? null : model.selectPhoto,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Foto do celular'),
                      ),
                      OutlinedButton(
                        onPressed: model.saving ? null : model.clearPhoto,
                        child: const Text('Usar apenas o avatar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (model.error != null) ...[
              const SizedBox(height: 12),
              Text(model.error!, style: TextStyle(color: colors.error)),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AgroAvatar.values.map((avatar) {
                final selected = avatar.id == model.appearance.avatarId &&
                    model.appearance.photoBase64 == null;
                return ChoiceChip(
                  selected: selected,
                  avatar: Icon(avatar.icon, size: 18),
                  label: Text(avatar.label),
                  onSelected: model.saving
                      ? null
                      : (_) => model.selectAvatar(avatar.id),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
