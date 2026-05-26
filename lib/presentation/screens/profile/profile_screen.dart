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
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final planName = user?.planName ?? 'N/A';
    final totalSessions = user?.totalSessions ?? 0;
    final remainingSessions = user?.remainingSessions ?? 0;
    final expiryDate = user?.expiryDate ?? 'N/A';
    final packageStatus = user?.packageStatus ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: [
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text('Gym ID: ${user?.gymId ?? '-'}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          AnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.card_membership_rounded),
                    SizedBox(width: 10),
                    Text(
                      'Current Plan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Plan', value: planName),
                const SizedBox(height: 10),
                _InfoRow(
                  label: 'Sessions',
                  value: '$remainingSessions / $totalSessions',
                ),
                const SizedBox(height: 10),
                _InfoRow(label: 'Expiry Date', value: expiryDate),
                const SizedBox(height: 10),
                _InfoRow(label: 'Status', value: packageStatus),
              ],
            ),
          ),

          const SizedBox(height: 14),

          AnimatedCard(
            onTap: () => context.push(
              AppRoutes.viewAll,
              extra: {
                'title': 'Wallet',
                'items': const ['Coins', 'Rewards', 'Transactions'],
              },
            ),
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}