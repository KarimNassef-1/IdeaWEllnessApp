import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/showcase_ai_images.dart';
import '../../../core/utils/time_greeting.dart';
import '../../../domain/entities/gym_session.dart';
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
    final highlights = content.partnerHighlights();
    final offers = content.specialOffers();
    final sessions = content.upcomingSessions();
    final allClasses = content.allClassesSchedule();
    final partners = content.partners();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('img/idea-app-icon.png', width: 52, height: 52),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    timeBasedGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ready for your next class?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            _title(context, 'Fresh Drops'),
            CarouselWidget(
              items: fresh
                  .map((img) => _imageCard(img, title: 'Gym update and announcements'))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _title(context, 'From Our Partners'),
            CarouselWidget(
              items: highlights
                  .map((img) => _imageCard(img, title: 'Partner campaigns'))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _title(context, 'Quick Shortcuts'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircularShortcutButton(
                  label: 'Schedule',
                  icon: Icons.calendar_today_rounded,
                  onTap: () => _openAllClasses(context, allClasses),
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
                  onTap: () => _openViewAll(context, 'Gyms', const [
                    'Nasr City Branch',
                    'New Cairo Branch',
                  ]),
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
                          Text(offer['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
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
            SectionHeader(
              title: 'Upcoming Sessions',
              actionLabel: 'View All',
              onAction: () => _openAllClasses(context, allClasses),
            ),
            CarouselWidget(
              autoScroll: false,
              height: 196,
              items: sessions.map((s) => _sessionCard(context, s)).toList(),
            ),
            const SizedBox(height: 18),
            _title(context, 'Our Partners'),
            const SizedBox(height: 8),
            GridView.builder(
              itemCount: partners.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final partner = partners[index];
                return GestureDetector(
                  onTap: () => context.push(AppRoutes.partnerDetail, extra: partner),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppImage(
                          source: partner['image'] ?? '',
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        partner['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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

  Widget _sessionCard(BuildContext context, GymSession s) {
    final showcaseImage = showcaseAiImage(
      'high action gym class ${s.name} coached by ${s.trainer} premium cinematic',
      seed: s.id.hashCode.abs() % 100000,
    );
    final levelLabel = s.name.contains('Ladies Only') ? 'Ladies Only' : 'All Levels';

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
                const Text(
                  'HELIOPOLIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Text(
                  s.name.toUpperCase(),
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
                  s.trainer,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0x33FFFFFF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${s.timeStart} to ${s.timeEnd}',
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x66A0A0A0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        levelLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  void _openViewAll(BuildContext context, String title, List<String> items) {
    context.push(AppRoutes.viewAll, extra: {'title': title, 'items': items});
  }

  void _openAllClasses(BuildContext context, List<GymSession> allClasses) {
    context.push(
      AppRoutes.viewAll,
      extra: {
        'title': 'All Classes',
        'mode': 'classes',
        'sessions': allClasses.map((s) => s.toMap()).toList(),
      },
    );
  }
}
