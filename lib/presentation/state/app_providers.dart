import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/rewards_repository_impl.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/entities/branch_summary.dart';
import '../../domain/entities/class_schedule_item.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/subscribed_class.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/rewards_repository.dart';
import 'auth_notifier.dart';

final contentRepositoryProvider = Provider<ContentRepository>((_) {
  return ContentRepositoryImpl();
});

final rewardsRepositoryProvider = Provider<RewardsRepository>((_) {
  return RewardsRepositoryImpl();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((_) {
  return DashboardRepository();
});

final branchesProvider = FutureProvider<List<BranchSummary>>((ref) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null || token.isEmpty) {
    return const [];
  }

  return ref.watch(dashboardRepositoryProvider).branches(token);
});

final subscribedClassesProvider = FutureProvider<List<SubscribedClass>>((
  ref,
) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null || token.isEmpty) {
    return const [];
  }

  return ref.watch(dashboardRepositoryProvider).subscribedClasses(token);
});

/// The branch the user has selected in the classes section.
/// null = member's home branch (API default).
final selectedClassBranchIdProvider = StateProvider<String?>((ref) => null);

/// Passes the selected branchId to the API; null means "home branch".
// ── Workout ───────────────────────────────────────────────────────────────────

final workoutRepositoryProvider = Provider<WorkoutRepository>((_) => WorkoutRepository());

final exerciseCategoriesProvider = FutureProvider<List<ExerciseCategory>>((ref) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null) return [];
  return ref.read(workoutRepositoryProvider).categories(token);
});

/// Selected category filter on the library tab (null = all).
final selectedExerciseCategoryProvider = StateProvider<int?>((ref) => null);

/// Search text on the library tab.
final exerciseSearchProvider = StateProvider<String>((ref) => '');

final exerciseListProvider = FutureProvider<List<ExerciseListItem>>((ref) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null) return [];
  final categoryId = ref.watch(selectedExerciseCategoryProvider);
  final search = ref.watch(exerciseSearchProvider);
  return ref.read(workoutRepositoryProvider).exercises(
        token,
        categoryId: categoryId,
        search: search.isEmpty ? null : search,
      );
});

final exerciseDetailProvider =
    FutureProvider.family<ExerciseDetail, String>((ref, exerciseId) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null) throw Exception('Not authenticated.');
  return ref.read(workoutRepositoryProvider).exerciseDetail(token, exerciseId);
});

final myWorkoutPlansProvider = FutureProvider<List<WorkoutPlanListItem>>((ref) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null) return [];
  return ref.read(workoutRepositoryProvider).myPlans(token);
});

final workoutPlanDetailProvider =
    FutureProvider.family<WorkoutPlanDetail, String>((ref, planId) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null) throw Exception('Not authenticated.');
  return ref.read(workoutRepositoryProvider).planDetail(token, planId);
});

// ── Today classes ─────────────────────────────────────────────────────────────

final todayClassesProvider = FutureProvider<TodayClasses>((ref) async {
  final token = ref.watch(authNotifierProvider).user?.token;
  if (token == null || token.isEmpty) {
    return const TodayClasses(myClasses: [], branchClasses: []);
  }

  final branchId = ref.watch(selectedClassBranchIdProvider);
  try {
    return await ref.watch(dashboardRepositoryProvider).todayClasses(token, branchId: branchId);
  } catch (e, st) {
    debugPrint('todayClassesProvider error: $e\n$st');
    return const TodayClasses(myClasses: [], branchClasses: []);
  }
});
