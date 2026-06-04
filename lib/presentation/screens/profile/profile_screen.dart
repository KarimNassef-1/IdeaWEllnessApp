import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../domain/entities/member_package_item.dart';
import '../../../domain/entities/member_partnership.dart';
import '../../state/app_providers.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/animated_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final packagesAsync = ref.watch(myPackagesProvider);
    final partnershipsAsync = ref.watch(myPartnershipsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: [
          // ── Avatar + name ──────────────────────────────────────────
          AnimatedCard(
            child: Row(
              children: [
                _MemberAvatar(profileImageUrl: user?.profileImageUrl, radius: 34),
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

          // ── Membership Plan (all active packages) ──────────────────
          _MembershipPlanCard(
            packagesAsync: packagesAsync,
            onRefresh: () => ref.invalidate(myPackagesProvider),
          ),
          const SizedBox(height: 14),

          // ── Partnerships ───────────────────────────────────────────
          _PartnershipsCard(partnershipsAsync: partnershipsAsync),
          const SizedBox(height: 14),

          // ── Freeze package action (still works on primary plan) ────
          if (user != null && user.canFreeze) ...[
            AnimatedCard(
              onTap: () => _showFreezeDialog(context, ref, user.freezeRemainingDays ?? 0),
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
                          'Up to ${user.freezeRemainingDays} days remaining',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

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
                ref.invalidate(myPackagesProvider);
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

// ── Membership Plan section ────────────────────────────────────────────
class _MembershipPlanCard extends StatelessWidget {
  const _MembershipPlanCard({
    required this.packagesAsync,
    required this.onRefresh,
  });

  final AsyncValue<List<MemberPackageItem>> packagesAsync;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_membership_rounded),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Membership Plan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          packagesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Could not load your plan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Text(
                      'No active packages.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                          height: 1,
                        ),
                      ),
                    _PackageBlock(item: items[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PackageBlock extends StatelessWidget {
  const _PackageBlock({required this.item});
  final MemberPackageItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                item.packageName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            const SizedBox(width: 8),
            _StatusChip(status: item.status),
          ],
        ),
        if (item.packageTypeName != null) ...[
          const SizedBox(height: 4),
          Text(
            item.packageTypeName!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (item.linkedClassName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.linkedClassName!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (item.linkedClassDay != null || item.linkedClassTime != null)
                        Text(
                          [
                            item.linkedClassDay,
                            item.linkedClassTime,
                          ].whereType<String>().join(' · '),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _InfoRow(
          label: 'Sessions',
          value: _sessionsLabel(item.sessionCountRemaining, item.sessionCountOriginal),
        ),
        const SizedBox(height: 6),
        _InfoRow(
          label: 'Branch',
          value: item.homeBranchName ?? '—',
        ),
        const SizedBox(height: 6),
        _InfoRow(label: 'Valid from', value: _formatDate(item.validFromDate)),
        const SizedBox(height: 6),
        _InfoRow(label: 'Expiry', value: _formatDate(item.validToDate ?? '')),
        if (item.isFrozen) ...[
          const SizedBox(height: 10),
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
                    'Frozen until ${_formatDate(item.frozenUntilDate ?? '')}',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (item.hasPerks) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if ((item.invitationsRemaining ?? 0) > 0)
                _PerkChip(
                  icon: Icons.person_add_alt_1_rounded,
                  label: '${item.invitationsRemaining} invitations',
                  color: Colors.purple,
                ),
              if ((item.ptSessionsRemaining ?? 0) > 0)
                _PerkChip(
                  icon: Icons.fitness_center_rounded,
                  label: '${item.ptSessionsRemaining} PT sessions',
                  color: Colors.orange,
                ),
              if ((item.inBodyRemaining ?? 0) > 0)
                _PerkChip(
                  icon: Icons.monitor_heart_rounded,
                  label: '${item.inBodyRemaining} InBody',
                  color: Colors.teal,
                ),
              if ((item.freezeRemainingDays ?? 0) > 0)
                _PerkChip(
                  icon: Icons.ac_unit_rounded,
                  label: '${item.freezeRemainingDays} freeze days',
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _sessionsLabel(int? remaining, int? total) {
    if (remaining == null && total == null) return 'Unlimited';
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
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

// ── Member avatar (network photo or asset fallback) ───────────────────────────
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.profileImageUrl, this.radius = 34});
  final String? profileImageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      final url = profileImageUrl!.startsWith('http')
          ? profileImageUrl!
          : '${ApiConfig.baseUrl}$profileImageUrl';
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (e, s) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage('img/idea-profile.png'),
    );
  }
}

// ── Partnerships card ─────────────────────────────────────────────────────────
class _PartnershipsCard extends StatelessWidget {
  const _PartnershipsCard({required this.partnershipsAsync});
  final AsyncValue<List<MemberPartnership>> partnershipsAsync;

  @override
  Widget build(BuildContext context) {
    return partnershipsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.handshake_rounded),
                  SizedBox(width: 10),
                  Text(
                    'Partnerships',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map((p) => _PartnershipRow(item: p)),
            ],
          ),
        );
      },
    );
  }
}

class _PartnershipRow extends StatelessWidget {
  const _PartnershipRow({required this.item});
  final MemberPartnership item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.logoImageUrl != null && item.logoImageUrl!.isNotEmpty
                ? Image.network(
                    item.logoImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => Icon(
                      Icons.handshake_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                  )
                : Icon(
                    Icons.handshake_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 12),
          // Name + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          // Discount badge
          if (item.discountPercentage != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4ED),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Text(
                '${item.discountPercentage!.toStringAsFixed(item.discountPercentage! % 1 == 0 ? 0 : 1)}% off',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF5B14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerkChip extends StatelessWidget {
  const _PerkChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

