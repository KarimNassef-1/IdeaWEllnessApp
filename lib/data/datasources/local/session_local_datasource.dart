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