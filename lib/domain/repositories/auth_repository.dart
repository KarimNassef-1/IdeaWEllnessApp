import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getPersistedSession();

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  /// Self-registration: creates a new member account and signs them in.
  Future<UserProfile> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  });

  /// Sign in or auto-register using a Google account.
  Future<UserProfile> googleSignIn();

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