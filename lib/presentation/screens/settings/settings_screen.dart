import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
            onChanged: (_) =>
                ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help'),
            subtitle: const Text('Support, FAQ, and contact your gym'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showHelpSheet(context),
          ),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help?',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Reach out to your gym and we\'ll get back to you.',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _HelpTile(
                icon: Icons.phone_rounded,
                label: 'Call the gym',
                onTap: () => _launch('tel:+201001234567'),
              ),
              const SizedBox(height: 10),
              _HelpTile(
                icon: Icons.email_rounded,
                label: 'Email support',
                onTap: () => _launch('mailto:support@ideawellness.com'),
              ),
              const SizedBox(height: 10),
              _HelpTile(
                icon: Icons.chat_bubble_rounded,
                label: 'WhatsApp',
                onTap: () =>
                    _launch('https://wa.me/201001234567'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.open_in_new_rounded, size: 16),
      onTap: onTap,
    );
  }
}
