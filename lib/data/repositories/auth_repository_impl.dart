import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final SessionLocalDataSource _local;

  @override
  Future<UserProfile?> getPersistedSession() async {
    final session = await _local.getSession();
    if (session == null) return null;

    return UserProfile(
      username: session['username'] as String,
      gymId: session['gymId'] as String,
      coins: session['coins'] as int,
      avatarAsset: 'img/idea-profile.png',
    );
  }

  @override
  Future<UserProfile> signIn({required String username, required String gymId}) async {
    final user = UserProfile(
      username: username.trim(),
      gymId: gymId.trim(),
      coins: 1240,
      avatarAsset: 'img/idea-profile.png',
    );
    await _local.saveSession(username: user.username, gymId: user.gymId, coins: user.coins);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _local.clearSession();
  }
}
