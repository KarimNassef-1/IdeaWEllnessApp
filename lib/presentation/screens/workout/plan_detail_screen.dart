import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../domain/entities/workout_plan.dart';
import '../../state/app_providers.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/app_image.dart';

class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(workoutPlanDetailProvider(planId));

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.valueOrNull?.planName ?? 'Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add exercise',
            onPressed: () async {
              await context.push(AppRoutes.exerciseLibraryPicker,
                  extra: planId);
              ref.invalidate(workoutPlanDetailProvider(planId));
            },
          ),
        ],
      ),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Could not load plan.')),
        data: (detail) => detail.exercises.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    const Text('No exercises yet.'),
                    const SizedBox(height: 6),
                    FilledButton.icon(
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Exercise'),
                      onPressed: () async {
                        await context.push(
                            AppRoutes.exerciseLibraryPicker,
                            extra: planId);
                        ref.invalidate(workoutPlanDetailProvider(planId));
                      },
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemCount: detail.exercises.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _PlanExerciseTile(
                  planId: planId,
                  entry: detail.exercises[index],
                ),
              ),
      ),
    );
  }
}

class _PlanExerciseTile extends ConsumerWidget {
  const _PlanExerciseTile({
    required this.planId,
    required this.entry,
  });
  final String planId;
  final WorkoutPlanExerciseItem entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(entry.memberWorkoutPlanExerciseId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) async {
        final token = ref.read(authNotifierProvider).user?.token;
        if (token == null) return;
        await ref.read(workoutRepositoryProvider).removeExerciseFromPlan(
              token,
              planId: planId,
              entryId: entry.memberWorkoutPlanExerciseId,
            );
        ref.invalidate(workoutPlanDetailProvider(planId));
      },
      child: GestureDetector(
        onTap: () => _showEditDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: entry.photoUrl != null
                      ? AppImage(
                          source: entry.photoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.exerciseName,
                        style:
                            const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(entry.categoryName,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (entry.volumeLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    entry.volumeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final setsCtrl =
        TextEditingController(text: entry.sets?.toString() ?? '');
    final repsCtrl =
        TextEditingController(text: entry.reps?.toString() ?? '');
    final durCtrl = TextEditingController(
        text: entry.durationSeconds?.toString() ?? '');
    final restCtrl = TextEditingController(
        text: entry.restSeconds?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entry.exerciseName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: durCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Duration (sec)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: restCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Rest (sec)'),
                  ),
                ),
              ],
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

              await ref
                  .read(workoutRepositoryProvider)
                  .updatePlanExercise(
                    token,
                    planId: planId,
                    entryId: entry.memberWorkoutPlanExerciseId,
                    sets: int.tryParse(setsCtrl.text),
                    reps: int.tryParse(repsCtrl.text),
                    durationSeconds: int.tryParse(durCtrl.text),
                    restSeconds: int.tryParse(restCtrl.text),
                  );
              ref.invalidate(workoutPlanDetailProvider(planId));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
