import 'dart:convert';

import 'package:agrohub_app/database/database_helper.dart';
import 'package:agrohub_app/models/profile_appearance.dart';
import 'package:agrohub_app/services/session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  static final ValueNotifier<int> changes = ValueNotifier(0);

  String _key(SessionData session) => 'profile_appearance_v1:${session.profileKey}';

  Future<ProfileAppearance> loadAppearance(SessionData session) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_key(session));
    if (stored == null) return const ProfileAppearance();
    try {
      return ProfileAppearance.fromJson(jsonDecode(stored) as Map<String, dynamic>);
    } catch (_) {
      return const ProfileAppearance();
    }
  }

  Future<void> saveAppearance(
    SessionData session,
    ProfileAppearance appearance,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _key(session),
      jsonEncode(appearance.toJson()),
    );
    if (!saved) throw StateError('Não foi possível salvar o perfil.');
    changes.value++;
  }

  Future<Map<String, dynamic>?> loadRecord(SessionData session) async {
    if (!const {'operadores', 'fazendas', 'comercios'}.contains(session.tableName)) {
      return null;
    }
    if (session.localId != null) {
      final record = await DatabaseHelper.instance.buscarPorId(
        session.tableName,
        session.localId!,
      );
      if (record != null) return record;
    }
    return DatabaseHelper.instance.buscarPorColuna(
      session.tableName,
      session.tableName == 'operadores' ? 'cpf' : 'documento',
      session.login,
    );
  }
}
