import 'dart:ui' as ui;
import 'dart:convert';

import 'package:agrohub_app/models/profile_appearance.dart';
import 'package:agrohub_app/repositories/profile_repository.dart';
import 'package:agrohub_app/services/local_image_service.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  final ProfileRepository _repository;
  SessionData? session;
  Map<String, dynamic>? record;
  ProfileAppearance appearance = const ProfileAppearance();
  bool loading = true;
  bool saving = false;
  String? error;
  bool _disposed = false;

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      session = await SessionService.loadSession();
      if (session != null && (session!.isAdmin || session!.isOperator)) {
        appearance = await _repository.loadAppearance(session!);
        record = await _repository.loadRecord(session!);
      } else {
        error = 'Entre na sua conta para visualizar o perfil.';
      }
    } catch (_) {
      error = 'Não foi possível carregar o perfil. Tente novamente.';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> selectAvatar(String avatarId) =>
      _save(ProfileAppearance(avatarId: avatarId));

  Future<void> clearPhoto() => selectAvatar(appearance.avatarId);

  Future<void> selectPhoto() async {
    if (saving || session == null) return;
    saving = true;
    error = null;
    _notify();
    try {
      final selected = await LocalImageService.pickImage();
      if (selected == null) return;
      final bytes = LocalImageService.decodeImage(selected.base64Data);
      if (bytes == null || bytes.length > 5 * 1024 * 1024) {
        error = 'Escolha uma imagem de até 5 MB.';
        return;
      }
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 512);
      late String photoBase64;
      try {
        final frame = await codec.getNextFrame();
        try {
          final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
          if (data == null) throw StateError('Imagem inválida.');
          photoBase64 = base64Encode(data.buffer.asUint8List());
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
      final updated = ProfileAppearance(
        avatarId: appearance.avatarId,
        photoBase64: photoBase64,
      );
      await _repository.saveAppearance(session!, updated);
      appearance = updated;
    } catch (_) {
      error = 'Não foi possível usar esta foto. Escolha uma imagem JPG ou PNG.';
    } finally {
      saving = false;
      _notify();
    }
  }

  Future<void> _save(ProfileAppearance updated) async {
    if (saving || session == null) return;
    saving = true;
    error = null;
    _notify();
    try {
      await _repository.saveAppearance(session!, updated);
      appearance = updated;
    } catch (_) {
      error = 'Não foi possível salvar seu avatar. Tente novamente.';
    } finally {
      saving = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
