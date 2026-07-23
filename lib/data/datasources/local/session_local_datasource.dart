import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionLocalDataSource {
  /// Sensitive secrets — the auth token and the saved "remember me" password —
  /// live in the OS keychain (iOS) / keystore (Android) via secure storage.
  /// Everything else (display name, ids, flags) stays in SharedPreferences.
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const _kToken = 'token';
  static const _kSavedPassword = 'saved_password';

  Future<void> saveSession({
    required String username,
    required String gymId,
    required int coins,
    required String token,
    required String memberId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', username);
    await prefs.setString('gymId', gymId);
    await prefs.setInt('coins', coins);
    await prefs.setString('memberId', memberId);
    await prefs.setString('email', email);
    await _secure.write(key: _kToken, value: token);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();

    final username = prefs.getString('username');
    final gymId = prefs.getString('gymId');

    if (username == null || gymId == null) return null;

    return {
      'username': username,
      'gymId': gymId,
      'coins': prefs.getInt('coins') ?? 0,
      'token': await _secure.read(key: _kToken),
      'memberId': prefs.getString('memberId'),
      'email': prefs.getString('email'),
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('gymId');
    await prefs.remove('coins');
    await prefs.remove('memberId');
    await prefs.remove('email');
    await _secure.delete(key: _kToken);
    // Note: saved "remember me" credentials are intentionally kept so the login
    // form can prefill after logout / session expiry. Cleared via clearCredentials().
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('themeMode');
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
  }

  // ── "Remember me" credentials (persist across logout) ─────────────────────

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setBool('remember_me', true);
    await _secure.write(key: _kSavedPassword, value: password);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.setBool('remember_me', false);
    await _secure.delete(key: _kSavedPassword);
  }

  /// Returns {'email', 'password'} when "remember me" was enabled, else null.
  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('remember_me') ?? false)) return null;
    final email = prefs.getString('saved_email');
    final password = await _secure.read(key: _kSavedPassword);
    if (email == null || password == null) return null;
    return {'email': email, 'password': password};
  }
}
