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
    this.memberPackageId,
    this.planName,
    this.totalSessions,
    this.remainingSessions,
    this.expiryDate,
    this.packageStatus,
    this.invitationsRemaining,
    this.inBodyRemaining,
    this.ptSessionsRemaining,
    this.freezeAllowanceDays,
    this.freezeRemainingDays,
    this.isFrozen = false,
    this.frozenFromDate,
    this.frozenUntilDate,
  });

  final String username;
  final String gymId;
  final int coins;
  final String avatarAsset;

  final String? memberId;
  final String? email;
  final String? token;
  final String? profileImageUrl;
  final String? membershipNumber;
  final String? memberPackageId;

  // Package
  final String? planName;
  final int? totalSessions;
  final int? remainingSessions;
  final String? expiryDate;
  final String? packageStatus;

  // Perks
  final int? invitationsRemaining;
  final int? inBodyRemaining;
  final int? ptSessionsRemaining;
  final int? freezeAllowanceDays;
  final int? freezeRemainingDays;

  // Freeze state
  final bool isFrozen;
  final String? frozenFromDate;
  final String? frozenUntilDate;

  bool get canFreeze =>
      !isFrozen &&
      (freezeRemainingDays ?? 0) > 0 &&
      (packageStatus?.toUpperCase() == 'ACTIVE');

  UserProfile copyWith({
    int? coins,
    String? token,
    String? profileImageUrl,
    String? membershipNumber,
    String? memberPackageId,
    String? planName,
    int? totalSessions,
    int? remainingSessions,
    String? expiryDate,
    String? packageStatus,
    int? invitationsRemaining,
    int? inBodyRemaining,
    int? ptSessionsRemaining,
    int? freezeAllowanceDays,
    int? freezeRemainingDays,
    bool? isFrozen,
    String? frozenFromDate,
    String? frozenUntilDate,
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
      memberPackageId: memberPackageId ?? this.memberPackageId,
      planName: planName ?? this.planName,
      totalSessions: totalSessions ?? this.totalSessions,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      expiryDate: expiryDate ?? this.expiryDate,
      packageStatus: packageStatus ?? this.packageStatus,
      invitationsRemaining: invitationsRemaining ?? this.invitationsRemaining,
      inBodyRemaining: inBodyRemaining ?? this.inBodyRemaining,
      ptSessionsRemaining: ptSessionsRemaining ?? this.ptSessionsRemaining,
      freezeAllowanceDays: freezeAllowanceDays ?? this.freezeAllowanceDays,
      freezeRemainingDays: freezeRemainingDays ?? this.freezeRemainingDays,
      isFrozen: isFrozen ?? this.isFrozen,
      frozenFromDate: frozenFromDate ?? this.frozenFromDate,
      frozenUntilDate: frozenUntilDate ?? this.frozenUntilDate,
    );
  }
}