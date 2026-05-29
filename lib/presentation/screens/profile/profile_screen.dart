import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/animated_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: [
          // ── Avatar + name ──────────────────────────────────────────
          AnimatedCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage: AssetImage(
                    user?.avatarAsset ?? 'img/idea-profile.png',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'Member',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${user?.membershipNumber ?? user?.gymId ?? '-'}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Package details ─────────────────────────────────────────
          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_membership_rounded),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user?.planName ?? 'No active plan',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    _StatusChip(status: user?.packageStatus),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Sessions', value: _sessionsLabel(user?.remainingSessions, user?.totalSessions)),
                const SizedBox(height: 8),
                _InfoRow(label: 'Valid from', value: user?.expiryDate != null ? _formatDate(user!.expiryDate!) : 'N/A'),
                const SizedBox(height: 8),
                _InfoRow(label: 'Expiry', value: user?.expiryDate != null ? _formatDate(user!.expiryDate!) : 'N/A'),

                // Frozen banner
                if (user?.isFrozen == true) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.ac_unit_rounded, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Package frozen until ${_formatDate(user!.frozenUntilDate ?? '')}',
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Perks grid ──────────────────────────────────────────────
          if (_hasAnyPerk(user))
            AnimatedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.redeem_rounded),
                      SizedBox(width: 10),
                      Text('Package Perks', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: [
                      if (user?.freezeRemainingDays != null)
                        _PerkTile(
                          icon: Icons.ac_unit_rounded,
                          label: 'Freeze',
                          value: '${user!.freezeRemainingDays} / ${user.freezeAllowanceDays ?? user.freezeRemainingDays} days',
                          color: Colors.blue,
                        ),
                      if (user?.invitationsRemaining != null)
                        _PerkTile(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Invitations',
                          value: '${user!.invitationsRemaining} left',
                          color: Colors.purple,
                        ),
                      if (user?.ptSessionsRemaining != null)
                        _PerkTile(
                          icon: Icons.fitness_center_rounded,
                          label: 'PT Sessions',
                          value: '${user!.ptSessionsRemaining} left',
                          color: Colors.orange,
                        ),
                      if (user?.inBodyRemaining != null)
                        _PerkTile(
                          icon: Icons.monitor_heart_rounded,
                          label: 'InBody',
                          value: '${user!.inBodyRemaining} left',
                          color: Colors.teal,
                        ),
                    ],
                  ),
                ],
              ),
            ),

          // ── Freeze package action ───────────────────────────────────
          if (user?.canFreeze == true) ...[
            const SizedBox(height: 14),
            AnimatedCard(
              onTap: () => _showFreezeDialog(context, ref, user!.freezeRemainingDays!),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.ac_unit_rounded, color: Colors.blue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Freeze Package', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          'Up to ${user!.freezeRemainingDays} days remaining',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Wallet ─────────────────────────────────────────────────
          AnimatedCard(
            onTap: () => context.push(AppRoutes.viewAll, extra: {
              'title': 'Wallet',
              'items': const ['Coins', 'Rewards', 'Transactions'],
            }),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded),
                SizedBox(width: 10),
                Text('Wallet', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AnimatedCard(
            onTap: () => context.push(AppRoutes.settings),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.settings_rounded),
              title: Text('Settings'),
              subtitle: Text('Theme and app preferences'),
            ),
          ),
          const SizedBox(height: 10),
          const AnimatedCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.help_outline_rounded),
              title: Text('Help'),
              subtitle: Text('Support, FAQ, and contact gym'),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedCard(
            onTap: () async => ref.read(authNotifierProvider.notifier).logout(),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout_rounded),
              title: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAnyPerk(user) =>
      user != null &&
      (user.freezeRemainingDays != null ||
          user.invitationsRemaining != null ||
          user.ptSessionsRemaining != null ||
          user.inBodyRemaining != null);

  String _sessionsLabel(int? remaining, int? total) {
    if (remaining == null && total == null) return 'N/A';
    if (total == null) return '$remaining left';
    return '$remaining / $total';
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return 'N/A';
    try {
      final parts = raw.split('-');
      if (parts.length < 3) return raw;
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _showFreezeDialog(
    BuildContext context,
    WidgetRef ref,
    int maxDays,
  ) async {
    int selectedDays = 1;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.ac_unit_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text('Freeze Package'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose how many days to freeze (1–$maxDays):'),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: selectedDays > 1
                        ? () => setState(() => selectedDays--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '$selectedDays ${selectedDays == 1 ? 'day' : 'days'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: selectedDays < maxDays
                        ? () => setState(() => selectedDays++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your package expiry will be extended by $selectedDays ${selectedDays == 1 ? 'day' : 'days'}.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final error = await ref
                    .read(authNotifierProvider.notifier)
                    .freezePackage(selectedDays);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Package frozen for $selectedDays ${selectedDays == 1 ? 'day' : 'days'}.'),
                      backgroundColor: error != null ? Colors.red : Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Confirm Freeze'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({this.status});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final s = status?.toUpperCase() ?? '';
    final color = switch (s) {
      'ACTIVE' => Colors.green,
      'FROZEN' => Colors.blue,
      'EXPIRED' => Colors.red,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.isEmpty ? 'N/A' : s,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _PerkTile extends StatelessWidget {
  const _PerkTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
