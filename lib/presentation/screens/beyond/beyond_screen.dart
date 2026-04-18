import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../state/app_providers.dart';
import '../../widgets/app_image.dart';
import '../../widgets/carousel_widget.dart';
import '../../widgets/section_header.dart';

class BeyondScreen extends ConsumerWidget {
  const BeyondScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(contentRepositoryProvider).fitnessTips();

    return Scaffold(
      appBar: AppBar(title: const Text('Beyond')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
        children: [
          Text(
            'Welcome to our mini newsroom packed with feel good tips, easy recipes and updates',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Fitness Tips',
            actionLabel: 'View All',
            onAction: () => context.push(
              AppRoutes.viewAll,
              extra: {
                'title': 'Fitness Tips',
                'items': tips.map((e) => e['title'] ?? '').toList(),
              },
            ),
          ),
          CarouselWidget(
            height: 210,
            autoScroll: false,
            onTap: (index) => context.push(AppRoutes.article, extra: tips[index]),
            items: tips
                .map(
                  (tip) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(source: tip['image'] ?? '', fit: BoxFit.cover),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Text(
                            tip['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
