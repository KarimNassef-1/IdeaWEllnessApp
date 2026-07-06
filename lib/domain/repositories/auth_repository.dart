import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getPersistedSession();

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<UserProfile> refreshProfile(String token);

  Future<UserProfile> freezePackage({
    required String token,
    required int durationDays,
  });

  Future<UserProfile> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();
}