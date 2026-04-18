import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getPersistedSession();
  Future<UserProfile> signIn({required String username, required String gymId});
  Future<void> signOut();
}
