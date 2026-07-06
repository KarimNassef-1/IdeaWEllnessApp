import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/showcase_ai_images.dart';
import '../../../core/utils/time_greeting.dart';
import '../../../domain/entities/branch_summary.dart';
import '../../../domain/entities/class_schedule_item.dart';
import '../../../domain/entities/member_partnership.dart';
import '../../state/app_providers.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/carousel_widget.dart';
import '../../widgets/circular_shortcut_button.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final fresh = content.freshDrops();
    final offers = content.specialOffers();
    final branches = ref.watch(branchesProvider);
    final selectedClassBranchId = ref.watch(selectedClassBranchIdProvider);
    final todayClassesAsync = ref.watch(todayClassesProvider);
    // All active partner brands, managed dynamically in the web admin.
    final partnershipsAsync = ref.watch(partnershipsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          children: [
            // Greeting block
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'img/idea-app-icon.png',
                      width: 52,
                      height: 52,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    timeBasedGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ready for your next class?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // ── Branch capacity (first section) ───────────────────────
            _capacitySection(context, branches),
            const SizedBox(height: 20),
            _title(context, 'Fresh Drops'),
            CarouselWidget(
              items: fresh
                  .map(
                    (img) =>
                        _imageCard(img, title: 'Gym update and announcements'),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            _partnersSection(context, partnershipsAsync),
            const SizedBox(height: 20),
            _title(context, 'Quick Shortcuts'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularShortcutButton(
                  label: 'Schedule',
                  icon: Icons.calendar_today_rounded,
                  onTap: () => _openClassItems(
                    context,
                    'Full Schedule',
                    todayClassesAsync.valueOrNull?.branchWeekClasses ?? [],
                  ),
                ),
                CircularShortcutButton(
                  label: 'Arenas',
                  icon: Icons.stadium_rounded,
                  onTap: () => _openViewAll(context, 'Arenas', const [
                    'Main Arena',
                    'Functional Arena',
                  ]),
                ),
                CircularShortcutButton(
                  label: 'Gyms',
                  icon: Icons.fitness_center_rounded,
                  onTap: () => _openViewAll(
                    context,
                    'Gyms',
                    branches.valueOrNull
                            ?.map((branch) => branch.branchName)
                            .toList() ??
                        const [],
                  ),
                ),
                CircularShortcutButton(
                  label: 'Badges',
                  icon: Icons.workspace_premium_rounded,
                  onTap: () => _openViewAll(context, 'Badges', const [
                    'Consistency Streak',
                    'Challenge Finisher',
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _branchClassSelector(context, ref, branches, selectedClassBranchId),
            const SizedBox(height: 18),
            SectionHeader(
              title: "My Classes Today",
              actionLabel: 'View All',
              onAction: () => _openClassItems(
                context,
                'My Classes Today',
                todayClassesAsync.valueOrNull?.myWeekClasses ?? [],
              ),
            ),
            _todayClassesStrip(context, todayClassesAsync, useMyClasses: true),
            const SizedBox(height: 18),
            SectionHeader(
              title: "Today's Classes${_selectedBranchLabel(branches.valueOrNull, selectedClassBranchId)}",
              actionLabel: 'View All',
              onAction: () => _openClassItems(
                context,
                "Today's Classes",
                todayClassesAsync.valueOrNull?.branchWeekClasses ?? [],
              ),
            ),
            _todayClassesStrip(context, todayClassesAsync, useMyClasses: false),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Special Offers',
              actionLabel: 'View All',
              onAction: () => _openViewAll(
                context,
                'Special Offers',
                offers.map((e) => e['title'] ?? '').toList(),
              ),
            ),
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return SizedBox(
                    width: 260,
                    child: AnimatedCard(
                      showShadow: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(offer['subtitle'] ?? ''),
                          const Spacer(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppImage(
                              source: offer['image'] ?? '',
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _imageCard(String image, {required String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(source: image, fit: BoxFit.cover),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Capacity section: hero ring for home + small rings for others ──
  Widget _capacitySection(
    BuildContext context,
    AsyncValue<List<BranchSummary>> branches,
  ) {
    return branches.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        height: 80,
        child: Center(child: Text('Branches are unavailable right now.')),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(child: Text('No accessible branches.')),
          );
        }

        final home = items.firstWhere(
          (b) => b.isHomeBranch,
          orElse: () => items.first,
        );
        final others = items.where((b) => b.branchId != home.branchId).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, 'Branch Capacity'),
            AnimatedCard(
              showShadow: false,
              child: Row(
                children: [
                  _HeroCapacityRing(branch: home),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.branchName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          home.displayLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Home',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (others.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: others.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final b = others[i];
                    return _SmallCapacityCard(branch: b);
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _branchClassSelector(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BranchSummary>> branches,
    String? selectedBranchId,
  ) {
    final items = branches.valueOrNull ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final branch = items[index];
          final isSelected = selectedBranchId == null
              ? index == 0
              : branch.branchId == selectedBranchId;

          return GestureDetector(
            onTap: () {
              // Selecting the first branch (index 0) resets to home branch (null = default)
              final newId = index == 0 ? null : branch.branchId;
              ref.read(selectedClassBranchIdProvider.notifier).state = newId;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                branch.branchName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _todayClassesStrip(
    BuildContext context,
    AsyncValue<TodayClasses> todayAsync, {
    required bool useMyClasses,
  }) {
    return todayAsync.when(
      loading: () => const SizedBox(
        height: 196,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(
        height: 196,
        child: Center(child: Text('Classes are unavailable right now.')),
      ),
      data: (today) {
        final items = useMyClasses ? today.myClasses : today.branchClasses;
        if (items.isEmpty) {
          return SizedBox(
            height: 196,
            child: _emptyStateCard(
              context,
              useMyClasses
                  ? 'No subscribed classes scheduled for today.'
                  : 'No classes at your branch today.',
            ),
          );
        }

        return CarouselWidget(
          autoScroll: false,
          height: 196,
          items: items.map((item) => _classCard(context, item)).toList(),
        );
      },
    );
  }

  Widget _classCard(BuildContext context, ClassScheduleItem item) {
    final showcaseImage = item.photoUrl?.isNotEmpty == true
        ? item.photoUrl!
        : showcaseAiImage(
            'high action gym class ${item.className} coached by ${item.coachName ?? "trainer"} premium cinematic',
            seed: item.gymClassId.hashCode.abs() % 100000,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(source: showcaseImage, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xCC000000)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.branchName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Text(
                  item.className.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.coachName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE6E6E6),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${item.timeStart} – ${item.timeEnd}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyStateCard(BuildContext context, String message) {
    return AnimatedCard(
      showShadow: false,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  String _selectedBranchLabel(List<BranchSummary>? branches, String? selectedId) {
    if (selectedId == null || branches == null) return '';
    final match = branches.where((b) => b.branchId == selectedId).firstOrNull;
    return match != null ? ' · ${match.branchName}' : '';
  }

  Widget _partnersSection(
    BuildContext context,
    AsyncValue<List<MemberPartnership>> partnershipsAsync,
  ) {
    return partnershipsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, 'Our Partners'),
            const SizedBox(height: 8),
            GridView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final p = items[index];
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: p.logoImageUrl != null && p.logoImageUrl!.isNotEmpty
                          ? AppImage(
                              source: p.logoImageUrl!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            )
                          : _partnerFallback(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (p.discountPercentage != null && p.discountPercentage! > 0)
                      Text(
                        '${p.discountPercentage!.toStringAsFixed(p.discountPercentage! % 1 == 0 ? 0 : 1)}% off',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF5B14),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _partnerFallback(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.handshake_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 26,
      ),
    );
  }

  void _openViewAll(BuildContext context, String title, List<String> items) {
    context.push(AppRoutes.viewAll, extra: {'title': title, 'items': items});
  }

  void _openClassItems(
    BuildContext context,
    String title,
    List<ClassScheduleItem> items,
  ) {
    context.push(
      AppRoutes.viewAll,
      extra: {
        'title': title,
        'mode': 'classes',
        'sessions': items.map((item) => item.toMap()).toList(),
      },
    );
  }
}

// ── Hero capacity ring (big one, no numbers) ──────────────────────────
class _HeroCapacityRing extends StatelessWidget {
  const _HeroCapacityRing({required this.branch});
  final BranchSummary branch;

  @override
  Widget build(BuildContext context) {
    final pct = branch.occupancyPercent;
    final color = _capacityColor(branch.occupancyRatio ?? 0);

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(96, 96),
            painter: _CapacityRingPainter(
              ratio: (branch.occupancyRatio ?? 0).toDouble(),
              color: color,
              trackColor: color.withValues(alpha: 0.15),
              strokeWidth: 10,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pct == null ? '–' : '$pct%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'full',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small capacity card for other accessible branches ─────────────────
class _SmallCapacityCard extends StatelessWidget {
  const _SmallCapacityCard({required this.branch});
  final BranchSummary branch;

  @override
  Widget build(BuildContext context) {
    final pct = branch.occupancyPercent;
    final color = _capacityColor(branch.occupancyRatio ?? 0);

    return SizedBox(
      width: 150,
      child: AnimatedCard(
        showShadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(44, 44),
                        painter: _CapacityRingPainter(
                          ratio: (branch.occupancyRatio ?? 0).toDouble(),
                          color: color,
                          trackColor: color.withValues(alpha: 0.15),
                          strokeWidth: 5,
                        ),
                      ),
                      Text(
                        pct == null ? '–' : '$pct%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (branch.crossBranchVisitsRemaining != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${branch.crossBranchVisitsRemaining} left',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              branch.branchName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              branch.displayLocation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

Color _capacityColor(double ratio) {
  if (ratio >= 0.9) return const Color(0xFFE53935);
  if (ratio >= 0.65) return const Color(0xFFFB8C00);
  return const Color(0xFF43A047);
}

class _CapacityRingPainter extends CustomPainter {
  _CapacityRingPainter({
    required this.ratio,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double ratio;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (ratio <= 0) return;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    final sweep = 2 * math.pi * ratio.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CapacityRingPainter old) =>
      old.ratio != ratio ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
