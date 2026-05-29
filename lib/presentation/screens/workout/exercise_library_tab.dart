import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../domain/entities/exercise.dart';
import '../../state/app_providers.dart';
import '../../widgets/app_image.dart';

class ExerciseLibraryTab extends ConsumerStatefulWidget {
  const ExerciseLibraryTab({super.key});

  @override
  ConsumerState<ExerciseLibraryTab> createState() => _ExerciseLibraryTabState();
}

class _ExerciseLibraryTabState extends ConsumerState<ExerciseLibraryTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(exerciseCategoriesProvider);
    final selectedCategory = ref.watch(selectedExerciseCategoryProvider);
    final exercises = ref.watch(exerciseListProvider);

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search exercises…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(exerciseSearchProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            onChanged: (value) =>
                ref.read(exerciseSearchProvider.notifier).state = value,
          ),
        ),

        // ── Category chips ──────────────────────────────────────────
        categories.when(
          loading: () => const SizedBox(height: 40),
          error: (_, __) => const SizedBox.shrink(),
          data: (cats) => SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: selectedCategory == null,
                  onTap: () => ref
                      .read(selectedExerciseCategoryProvider.notifier)
                      .state = null,
                ),
                ...cats.map((c) => _CategoryChip(
                      label: c.categoryName,
                      selected: selectedCategory == c.exerciseCategoryId,
                      onTap: () => ref
                          .read(selectedExerciseCategoryProvider.notifier)
                          .state = c.exerciseCategoryId,
                    )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Exercise list ───────────────────────────────────────────
        Expanded(
          child: exercises.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
                child: Text('Could not load exercises.')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('No exercises found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _ExerciseTile(exercise: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});
  final ExerciseListItem exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.exerciseDetail,
        extra: exercise.exerciseId,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: SizedBox(
                width: 80,
                height: 80,
                child: exercise.photoUrl != null
                    ? AppImage(
                        source: exercise.photoUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.categoryName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (exercise.primaryMuscles.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        exercise.primaryMuscles.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _DifficultyBadge(difficulty: exercise.difficulty),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
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
      2 => 'Inter.',
      _ => 'Advanced',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
