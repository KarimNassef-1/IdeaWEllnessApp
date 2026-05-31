import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getPersistedSession();

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<UserProfile> refreshProfile(String token);

  Future<void> signOut();
}