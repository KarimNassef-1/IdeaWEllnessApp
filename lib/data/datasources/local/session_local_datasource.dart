import 'package:shared_preferences/shared_preferences.dart';

class SessionLocalDataSource {
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
    await prefs.setString('token', token);
    await prefs.setString('memberId', memberId);
    await prefs.setString('email', email);
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
      'token': prefs.getString('token'),
      'memberId': prefs.getString('memberId'),
      'email': prefs.getString('email'),
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('gymId');
    await prefs.remove('coins');
    await prefs.remove('token');
    await prefs.remove('memberId');
    await prefs.remove('email');
    // Note: saved "remember me" credentials are intentionally kept so the login
    // form can prefill after logout / session expiry. Cleared via clearCredentials().
  }

  // ── "Remember me" credentials (persist across logout) ─────────────────────

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
    await prefs.setBool('remember_me', true);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
  }

  /// Returns {'email', 'password'} when "remember me" was enabled, else null.
  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('remember_me') ?? false)) return null;
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    if (email == null || password == null) return null;
    return {'email': email, 'password': password};
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('themeMode');
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
  }
}