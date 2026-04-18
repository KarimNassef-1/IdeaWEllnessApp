import '../entities/coin_transaction.dart';
import '../entities/reward.dart';

abstract class RewardsRepository {
  List<Map<String, String>> earnWays();
  List<Reward> rewards();
  List<CoinTransaction> transactions();
}
