import 'package:agrohub_app/models/profile_appearance.dart';
import 'package:agrohub_app/repositories/profile_repository.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/material.dart';

class AgroAvatar {
  const AgroAvatar(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;

  static const values = [
    AgroAvatar('farmer', 'Agricultor', Icons.agriculture),
    AgroAvatar('grower', 'Cultivador', Icons.grass),
    AgroAvatar('gardener', 'Jardineiro', Icons.local_florist),
    AgroAvatar('ranger', 'Guardião da mata', Icons.forest),
    AgroAvatar('technician', 'Técnico agrícola', Icons.engineering),
    AgroAvatar('merchant', 'Comerciante', Icons.storefront),
    AgroAvatar('harvest', 'Colheita', Icons.eco),
    AgroAvatar('irrigation', 'Irrigação', Icons.water_drop),
  ];

  static AgroAvatar forId(String id) => values.firstWhere(
        (avatar) => avatar.id == id,
        orElse: () => values.first,
      );
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.appearance = const ProfileAppearance(),
    this.radius = 36,
  });

  final ProfileAppearance appearance;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final image = LocalImageService.decodeImage(appearance.photoBase64);
    final avatar = AgroAvatar.forId(appearance.avatarId);
    final fallback = Icon(avatar.icon,
        size: radius, color: colors.onPrimaryContainer);
    return Semantics(
      label: image == null ? 'Avatar: ${avatar.label}' : 'Foto do perfil',
      image: true,
      child: ClipOval(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          color: colors.primaryContainer,
          alignment: Alignment.center,
          child: image == null
              ? fallback
              : Image.memory(
                  image,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback,
                ),
        ),
      ),
    );
  }
}

class SessionProfileAvatar extends StatefulWidget {
  const SessionProfileAvatar({super.key, this.radius = 36});
  final double radius;

  @override
  State<SessionProfileAvatar> createState() => _SessionProfileAvatarState();
}

class _SessionProfileAvatarState extends State<SessionProfileAvatar> {
  ProfileAppearance _appearance = const ProfileAppearance();

  @override
  void initState() {
    super.initState();
    ProfileRepository.changes.addListener(_load);
    _load();
  }

  Future<void> _load() async {
    final session = await SessionService.loadSession();
    final appearance = session == null
        ? const ProfileAppearance()
        : await ProfileRepository().loadAppearance(session);
    if (mounted) setState(() => _appearance = appearance);
  }

  @override
  void dispose() {
    ProfileRepository.changes.removeListener(_load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ProfileAvatar(appearance: _appearance, radius: widget.radius);
}
