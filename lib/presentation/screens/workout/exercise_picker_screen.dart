import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/exercise.dart';
import '../../state/app_providers.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/app_image.dart';

/// Full-screen exercise browser that lets the user pick an exercise to add
/// to a workout plan. [planId] is passed via route extra.
class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key, required this.planId});
  final String planId;

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState
    extends ConsumerState<ExercisePickerScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(exerciseCategoriesProvider);
    final selectedCat = ref.watch(selectedExerciseCategoryProvider);
    final exercises = ref.watch(exerciseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search exercises…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(exerciseSearchProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              onChanged: (v) =>
                  ref.read(exerciseSearchProvider.notifier).state = v,
            ),
          ),

          // Category chips
          categories.when(
            loading: () => const SizedBox(height: 40),
            error: (_, _) => const SizedBox.shrink(),
            data: (cats) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _Chip(
                    label: 'All',
                    selected: selectedCat == null,
                    onTap: () => ref
                        .read(selectedExerciseCategoryProvider.notifier)
                        .state = null,
                  ),
                  ...cats.map((c) => _Chip(
                        label: c.categoryName,
                        selected: selectedCat == c.exerciseCategoryId,
                        onTap: () => ref
                            .read(
                                selectedExerciseCategoryProvider.notifier)
                            .state = c.exerciseCategoryId,
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: exercises.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  const Center(child: Text('Could not load exercises.')),
              data: (items) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) => _PickerTile(
                  exercise: items[index],
                  planId: widget.planId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends ConsumerWidget {
  const _PickerTile({required this.exercise, required this.planId});
  final ExerciseListItem exercise;
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: exercise.photoUrl != null
                    ? AppImage(
                        source: exercise.photoUrl!, fit: BoxFit.cover)
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        child: Icon(Icons.fitness_center_rounded,
                            color:
                                Theme.of(context).colorScheme.primary),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.exerciseName,
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                  Text(exercise.categoryName,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.add_circle_rounded,
                color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '10');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exercise.exerciseName),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sets'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final token =
                  ref.read(authNotifierProvider).user?.token;
              if (token == null) return;

              try {
                await ref
                    .read(workoutRepositoryProvider)
                    .addExerciseToPlan(
                      token,
                      planId: planId,
                      exerciseId: exercise.exerciseId,
                      sets: int.tryParse(setsCtrl.text),
                      reps: int.tryParse(repsCtrl.text),
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${exercise.exerciseName} added to plan.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap});
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
