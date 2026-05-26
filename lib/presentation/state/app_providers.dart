import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/rewards_repository_impl.dart';
import '../../domain/entities/branch_summary.dart';
import '../../domain/entities/subscribed_class.dart';
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
