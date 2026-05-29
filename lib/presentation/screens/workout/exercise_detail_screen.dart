import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/exercise.dart';
import '../../state/app_providers.dart';
import '../../widgets/app_image.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(exerciseDetailProvider(exerciseId));

    return Scaffold(
      body: detail.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load exercise.'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(exerciseDetailProvider(exerciseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (ex) => _ExerciseDetailBody(exercise: ex),
      ),
    );
  }
}

class _ExerciseDetailBody extends StatelessWidget {
  const _ExerciseDetailBody({required this.exercise});
  final ExerciseDetail exercise;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero image + back button ────────────────────────────────
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: exercise.photoUrl != null
                ? AppImage(source: exercise.photoUrl!, fit: BoxFit.cover)
                : Container(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Name + difficulty
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      exercise.exerciseName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _DifficultyChip(difficulty: exercise.difficulty),
                ],
              ),
              const SizedBox(height: 8),

              // Category & equipment chips
              Wrap(
                spacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.category_rounded,
                    label: exercise.categoryName,
                  ),
                  if (exercise.equipment != null &&
                      exercise.equipment!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.build_rounded,
                      label: exercise.equipment!,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Muscle groups
              if (exercise.muscleGroups.isNotEmpty) ...[
                _SectionTitle('Muscles Targeted'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: exercise.muscleGroups
                      .map((m) => _MuscleBadge(muscle: m))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Description
              if (exercise.description != null &&
                  exercise.description!.isNotEmpty) ...[
                _SectionTitle('About'),
                const SizedBox(height: 6),
                Text(exercise.description!),
                const SizedBox(height: 16),
              ],

              // Instructions
              if (exercise.instructions != null &&
                  exercise.instructions!.isNotEmpty) ...[
                _SectionTitle('How To'),
                const SizedBox(height: 6),
                Text(exercise.instructions!),
                const SizedBox(height: 16),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      );
}

class _MuscleBadge extends StatelessWidget {
  const _MuscleBadge({required this.muscle});
  final MuscleGroupInfo muscle;

  @override
  Widget build(BuildContext context) {
    final color =
        muscle.isPrimary ? Theme.of(context).colorScheme.primary : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${muscle.isPrimary ? '● ' : '○ '}${muscle.muscleGroupName}',
        style: TextStyle(
            fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      1 => Colors.green,
      2 => Colors.orange,
      _ => Colors.red,
    };
    final label = switch (difficulty) {
      1 => 'Beginner',
      2 => 'Intermediate',
      _ => 'Advanced',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
