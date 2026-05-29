import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../domain/entities/workout_plan.dart';
import '../../state/app_providers.dart';
import '../../state/auth_notifier.dart';

class MyPlansTab extends ConsumerWidget {
  const MyPlansTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(myWorkoutPlansProvider);

    return plans.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('Could not load plans.')),
      data: (items) => Stack(
        children: [
          items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fitness_center_rounded,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text('No workout plans yet.'),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap + to create your first plan.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _PlanTile(plan: items[index]),
                ),

          // FAB
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: 'newPlanFab',
              onPressed: () => _showCreateDialog(context, ref),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    int? selectedDay;

    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Workout Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan name',
                  hintText: 'e.g. Push Day',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Pin to day (optional)'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: List.generate(
                  7,
                  (i) => ChoiceChip(
                    label: Text(days[i]),
                    selected: selectedDay == i,
                    onSelected: (v) =>
                        setState(() => selectedDay = v ? i : null),
                  ),
                ),
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
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);

                final token = ref.read(authNotifierProvider).user?.token;
                if (token == null) return;

                try {
                  await ref
                      .read(workoutRepositoryProvider)
                      .createPlan(token,
                          planName: name, dayOfWeek: selectedDay);
                  ref.invalidate(myWorkoutPlansProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan});
  final WorkoutPlanListItem plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(plan.memberWorkoutPlanId),
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
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Plan?'),
            content: Text('Delete "${plan.planName}"?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete')),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        final token = ref.read(authNotifierProvider).user?.token;
        if (token == null) return;
        await ref
            .read(workoutRepositoryProvider)
            .deletePlan(token, plan.memberWorkoutPlanId);
        ref.invalidate(myWorkoutPlansProvider);
      },
      child: GestureDetector(
        onTap: () => context.push(
          AppRoutes.workoutPlanDetail,
          extra: plan.memberWorkoutPlanId,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center_rounded,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.planName,
                        style:
                            const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(
                      '${plan.exerciseCount} exercise${plan.exerciseCount == 1 ? '' : 's'}  ·  ${plan.dayLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
