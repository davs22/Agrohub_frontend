import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  final String role;
  final String login;
  final String tableName;
  final int? localId;
  final String? displayName;
  final String? documento;
  final String? token;

  const SessionData({
    required this.role,
    required this.login,
    required this.tableName,
    this.localId,
    this.displayName,
    this.documento,
    this.token,
  });
}

class SessionService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _roleKey = 'role';
  static const String _loginKey = 'login';
  static const String _tableNameKey = 'table_name';
  static const String _localIdKey = 'local_id';
  static const String _displayNameKey = 'display_name';
  static const String _documentoKey = 'documento';
  static const String _tokenKey = 'token';

  static Future<void> saveSession({
    required String role,
    required String login,
    required String tableName,
    int? localId,
    String? displayName,
    String? documento,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_loginKey, login);
    await prefs.setString(_tableNameKey, tableName);

    if (localId != null) {
      await prefs.setInt(_localIdKey, localId);
    } else {
      await prefs.remove(_localIdKey);
    }

    if (displayName != null) {
      await prefs.setString(_displayNameKey, displayName);
    } else {
      await prefs.remove(_displayNameKey);
    }

    if (documento != null) {
      await prefs.setString(_documentoKey, documento);
    } else {
      await prefs.remove(_documentoKey);
    }

    await prefs.setString(_tokenKey, token ?? 'LOCAL_SESSION');
  }

  static Future<SessionData?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (!isLoggedIn) {
      return null;
    }

    final role = prefs.getString(_roleKey);
    final login = prefs.getString(_loginKey);
    final tableName = prefs.getString(_tableNameKey);

    if (role == null || login == null || tableName == null) {
      return null;
    }

    return SessionData(
      role: role,
      login: login,
      tableName: tableName,
      localId: prefs.getInt(_localIdKey),
      displayName: prefs.getString(_displayNameKey),
      documento: prefs.getString(_documentoKey),
      token: prefs.getString(_tokenKey),
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_loginKey);
    await prefs.remove(_tableNameKey);
    await prefs.remove(_localIdKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_documentoKey);
    await prefs.remove(_tokenKey);
  }
}
