import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../state/app_providers.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/carousel_widget.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/section_header.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsRepo = ref.watch(rewardsRepositoryProvider);
    final user = ref.watch(authNotifierProvider).user;
    final earnWays = rewardsRepo.earnWays();
    final rewards = rewardsRepo.rewards();
    final tx = rewardsRepo.transactions();

    return Scaffold(
      appBar: AppBar(title: const Text('Idea Wellness Rewards')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: [
          AnimatedCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Coin Balance', style: TextStyle(fontWeight: FontWeight.w700)),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: user?.coins ?? 0),
                  duration: const Duration(milliseconds: 900),
                  builder: (context, value, child) => Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _quickCard(context, 'Unlocked Rewards', '${rewards.length} items')),
              const SizedBox(width: 10),
              Expanded(child: _quickCard(context, 'About Coins', 'How to use')),
              const SizedBox(width: 10),
              Expanded(child: _quickCard(context, 'Recent Activity', '${tx.length} logs')),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Earn Coins',
            actionLabel: 'View All',
            onAction: () => context.push(AppRoutes.viewAll, extra: {
              'title': 'Earn Coins',
              'items': earnWays.map((e) => '${e['title']} ${e['points']}').toList(),
            }),
          ),
          ...earnWays.map(
            (way) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedCard(
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded),
                    const SizedBox(width: 10),
                    Expanded(child: Text(way['title'] ?? '')),
                    Text(
                      way['points'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SectionHeader(title: 'Claim Rewards'),
          CarouselWidget(
            autoScroll: false,
            height: 220,
            items: rewards.map((reward) {
              return AnimatedCard(
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppImage(
                          source: reward.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(reward.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${reward.coinCost} coins'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Claim — ${reward.coinCost} coins',
                            onPressed: user == null || (user.coins) < reward.coinCost
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Rewards redemption coming soon.'),
                                      ),
                                    );
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(BuildContext context, String title, String subtitle) {
    return AnimatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
