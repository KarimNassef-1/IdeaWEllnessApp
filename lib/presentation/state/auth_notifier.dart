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
    state = state.copyWith(loading: false, user: user, clearUser: user == null);
  }

  Future<bool> login({required String username, required String gymId}) async {
    if (username.trim().isEmpty || gymId.trim().isEmpty) return false;
    state = state.copyWith(loading: true);
    final user = await _repo.signIn(username: username, gymId: gymId);
    state = state.copyWith(loading: false, user: user);
    return true;
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = state.copyWith(clearUser: true);
  }
}
