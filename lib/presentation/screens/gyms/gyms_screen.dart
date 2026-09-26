import 'package:flutter/material.dart';

import '../../../core/data/gyms_catalog.dart';
import '../../widgets/app_image.dart';

/// Photo gallery of gym branches. Each branch shows its name, location and a
/// swipeable set of its own photos (bundled under `img/branches/`).
class GymsScreen extends StatelessWidget {
  const GymsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gyms')),
      body: gymsCatalog.isEmpty
          ? const Center(child: Text('No gyms available yet.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: gymsCatalog.length,
              separatorBuilder: (_, _) => const SizedBox(height: 24),
              itemBuilder: (context, index) => _GymCard(gym: gymsCatalog[index]),
            ),
    );
  }
}

class _GymCard extends StatefulWidget {
  const _GymCard({required this.gym});
  final Gym gym;

  @override
  State<_GymCard> createState() => _GymCardState();
}

class _GymCardState extends State<_GymCard> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gym = widget.gym;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gym.name,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        if (gym.comingSoon)
          Text(
            'Coming soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
          )
        else if (gym.location.isNotEmpty)
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 15, color: scheme.primary),
              const SizedBox(width: 4),
              Text(
                gym.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5D5D5D),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: gym.photos.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => AppImage(
                    source: gym.photos[i],
                    fit: BoxFit.cover,
                  ),
                ),
                if (gym.comingSoon)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                if (gym.photos.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        gym.photos.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? scheme.primary
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (gym.description != null && gym.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            gym.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
