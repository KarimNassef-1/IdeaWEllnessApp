class UserProfile {
  const UserProfile({
    required this.username,
    required this.gymId,
    required this.coins,
    required this.avatarAsset,
    this.memberId,
    this.email,
    this.token,
    this.profileImageUrl,
    this.membershipNumber,
    this.planName,
    this.totalSessions,
    this.remainingSessions,
    this.expiryDate,
    this.packageStatus,
  });

  final String username;
  final String gymId;
  final int coins;
  final String avatarAsset;

  // Real fields from backend
  final String? memberId;
  final String? email;
  final String? token;
  final String? profileImageUrl;
  final String? membershipNumber;

  // Package fields
  final String? planName;
  final int? totalSessions;
  final int? remainingSessions;
  final String? expiryDate;
  final String? packageStatus;

  UserProfile copyWith({
    int? coins,
    String? token,
    String? profileImageUrl,
    String? membershipNumber,
    String? planName,
    int? totalSessions,
    int? remainingSessions,
    String? expiryDate,
    String? packageStatus,
  }) {
    return UserProfile(
      username: username,
      gymId: gymId,
      coins: coins ?? this.coins,
      avatarAsset: avatarAsset,
      memberId: memberId,
      email: email,
      token: token ?? this.token,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      planName: planName ?? this.planName,
      totalSessions: totalSessions ?? this.totalSessions,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      expiryDate: expiryDate ?? this.expiryDate,
      packageStatus: packageStatus ?? this.packageStatus,
    );
  }
}