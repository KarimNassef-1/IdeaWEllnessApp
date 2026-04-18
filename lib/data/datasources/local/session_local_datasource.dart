import 'package:shared_preferences/shared_preferences.dart';

class SessionLocalDataSource {
  static const _themeKey = 'theme_mode';
  static const _usernameKey = 'username';
  static const _gymIdKey = 'gym_id';
  static const _coinsKey = 'coins';

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> saveSession({
    required String username,
    required String gymId,
    required int coins,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_gymIdKey, gymId);
    await prefs.setInt(_coinsKey, coins);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final gymId = prefs.getString(_gymIdKey);
    final coins = prefs.getInt(_coinsKey);

    if (username == null || gymId == null || coins == null) {
      return null;
    }

    return {'username': username, 'gymId': gymId, 'coins': coins};
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_gymIdKey);
    await prefs.remove(_coinsKey);
  }
}
