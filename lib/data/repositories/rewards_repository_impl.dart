import '../../domain/entities/coin_transaction.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../../core/utils/showcase_ai_images.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  String _img(String prompt, int seed) {
    return showcaseAiImage(prompt, seed: seed);
  }

  @override
  List<Map<String, String>> earnWays() {
    return const [
      {'title': 'Gym Check-ins', 'points': '+30 per day'},
      {'title': 'Workout Completion', 'points': '+50 each'},
      {'title': 'Session Attendance', 'points': '+80 each'},
      {'title': 'Challenge Milestones', 'points': '+120 bonus'},
    ];
  }

  @override
  List<Reward> rewards() {
    return [
      Reward(
        id: 'r1',
        title: 'Protein Bar Box',
        image: _img('protein bar box product photo premium gym nutrition', 61),
        coinCost: 600,
      ),
      Reward(
        id: 'r2',
        title: 'Massage Session',
        image: _img('massage therapy wellness spa room premium vibe', 62),
        coinCost: 1200,
      ),
      Reward(
        id: 'r3',
        title: 'VIP Recovery Pass',
        image: _img('athlete recovery lounge infrared therapy premium', 63),
        coinCost: 2000,
      ),
    ];
  }

  @override
  List<CoinTransaction> transactions() {
    return [
      CoinTransaction(
        id: 't1',
        title: 'Check-in Reward',
        points: 30,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CoinTransaction(
        id: 't2',
        title: 'HIIT Session Completed',
        points: 80,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CoinTransaction(
        id: 't3',
        title: 'Claimed Protein Bar Box',
        points: -600,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
