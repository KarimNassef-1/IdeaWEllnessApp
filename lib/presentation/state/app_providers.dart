import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/rewards_repository_impl.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/rewards_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>((_) {
  return ContentRepositoryImpl();
});

final rewardsRepositoryProvider = Provider<RewardsRepository>((_) {
  return RewardsRepositoryImpl();
});
