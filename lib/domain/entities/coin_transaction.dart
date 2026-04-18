class CoinTransaction {
  const CoinTransaction({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
  });

  final String id;
  final String title;
  final int points;
  final DateTime date;
}
