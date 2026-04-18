import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/session_local_datasource.dart';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(SessionLocalDataSource());
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._local) : super(ThemeMode.light) {
    _loadTheme();
  }

  final SessionLocalDataSource _local;

  Future<void> _loadTheme() async {
    final mode = await _local.getThemeMode();
    if (mode == 'dark') {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _local.saveThemeMode(state == ThemeMode.dark ? 'dark' : 'light');
  }
}
