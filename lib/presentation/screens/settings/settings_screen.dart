import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/theme_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile.adaptive(
            value: mode == ThemeMode.dark,
            title: const Text('Dark Mode'),
            subtitle: const Text('Instantly switch luxury theme modes'),
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          const ListTile(
            leading: Icon(Icons.help_outline_rounded),
            title: Text('Help'),
            subtitle: Text('Support, FAQ, and contact your gym'),
          ),
        ],
      ),
    );
  }
}
