import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/session_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo)..restoreSession();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final local = ref.watch(sessionLocalDataSourceProvider);
  return AuthRepositoryImpl(local);
});

final sessionLocalDataSourceProvider = Provider<SessionLocalDataSource>((_) {
  return SessionLocalDataSource();
});

class AuthState {
  const AuthState({
    required this.loading,
    required this.user,
  });

  final bool loading;
  final UserProfile? user;

  bool get isAuthenticated => user != null;

  AuthState copyWith({bool? loading, UserProfile? user, bool clearUser = false}) {
    return AuthState(
      loading: loading ?? this.loading,
      user: clearUser ? null : (user ?? this.user),
    );
  }

  static const initial = AuthState(loading: false, user: null);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(AuthState.initial);

  final AuthRepository _repo;

  Future<void> restoreSession() async {
    state = state.copyWith(loading: true);
    final user = await _repo.getPersistedSession();
    if (user == null) {
      state = state.copyWith(loading: false, clearUser: true);
      return;
    }
    try {
      final fresh = await _repo.refreshProfile(user.token!);
      state = state.copyWith(loading: false, user: fresh);
    } catch (_) {
      // No network — fall back to cached basic profile.
      state = state.copyWith(loading: false, user: user);
    }
  }

Future<bool> login({required String email, required String password}) async {
  if (email.trim().isEmpty || password.trim().isEmpty) return false;
  state = state.copyWith(loading: true);
  try {
    final user = await _repo.signIn(email: email, password: password);
    state = state.copyWith(loading: false, user: user);
    return true;
  } catch (e) {
    state = state.copyWith(loading: false);
    return false;
  }
}

  /// Returns null on success, or an error message string on failure.
  Future<String?> freezePackage(int durationDays) async {
    final token = state.user?.token;
    if (token == null) return 'Not authenticated.';

    try {
      final updated = await _repo.freezePackage(
        token: token,
        durationDays: durationDays,
      );
      state = state.copyWith(user: updated);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = state.user?.token;
    if (token == null) return 'Not authenticated.';

    try {
      final updated = await _repo.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(user: updated);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = state.copyWith(clearUser: true);
  }
}
