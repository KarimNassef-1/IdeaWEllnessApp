class UserProfile {
  const UserProfile({
    required this.username,
    required this.gymId,
    required this.coins,
    required this.avatarAsset,
  });

  final String username;
  final String gymId;
  final int coins;
  final String avatarAsset;

  UserProfile copyWith({int? coins}) {
    return UserProfile(
      username: username,
      gymId: gymId,
      coins: coins ?? this.coins,
      avatarAsset: avatarAsset,
    );
  }
}
