import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/network/session_expiry.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final SessionLocalDataSource _local;

  static String get _baseUrl => ApiConfig.baseUrl;

  @override
  Future<UserProfile?> getPersistedSession() async {
    final session = await _local.getSession();
    if (session == null) return null;

    return UserProfile(
      username: session['username'] as String,
      gymId: session['gymId'] as String,
      coins: session['coins'] as int,
      avatarAsset: 'img/idea-profile.png',
      token: session['token'] as String?,
      memberId: session['memberId'] as String?,
      email: session['email'] as String?,
    );
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;

      final user = await getProfile(token);

      await _local.saveSession(
        username: user.username,
        gymId: user.gymId,
        coins: user.coins,
        token: user.token!,
        memberId: user.memberId!,
        email: user.email!,
      );

      return user;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email or password.');
    } else {
      throw Exception('Login failed. Please try again.');
    }
  }

  @override
  Future<UserProfile> refreshProfile(String token) => getProfile(token);

  Future<UserProfile> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return UserProfile(
        username: data['fullName'] as String,
        gymId: data['memberId'] as String,
        coins: data['coins'] as int? ?? 0,
        avatarAsset: 'img/idea-profile.png',
        memberId: data['memberId'] as String?,
        email: data['email'] as String?,
        profileImageUrl: data['profileImageUrl'] as String?,
        membershipNumber: data['membershipNumber'] as String?,
        memberPackageId: data['memberPackageId'] as String?,
        planName: data['planName'] as String?,
        totalSessions: data['totalSessions'] as int?,
        remainingSessions: data['remainingSessions'] as int?,
        validFromDate: data['validFromDate']?.toString(),
        expiryDate: data['expiryDate']?.toString(),
        packageStatus: data['packageStatus'] as String?,
        invitationsRemaining: data['invitationsRemaining'] as int?,
        inBodyRemaining: data['inBodyRemaining'] as int?,
        ptSessionsRemaining: data['ptSessionsRemaining'] as int?,
        freezeAllowanceDays: data['freezeAllowanceDays'] as int?,
        freezeRemainingDays: data['freezeRemainingDays'] as int?,
        isFrozen: data['isFrozen'] as bool? ?? false,
        frozenFromDate: data['frozenFromDate']?.toString(),
        frozenUntilDate: data['frozenUntilDate']?.toString(),
        mustChangePassword: data['mustChangePassword'] as bool? ?? false,
        token: token,
      );
    }

    // Expired/invalid token → trigger a global logout and stop.
    throwIfUnauthorized(response.statusCode);
    throw Exception('Failed to load profile');
  }

  @override
  Future<UserProfile> freezePackage({
    required String token,
    required int durationDays,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/freeze'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'durationDays': durationDays}),
    );

    if (response.statusCode == 200) {
      // Re-fetch the full profile so all perk counters are up to date
      return getProfile(token);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['message'] ?? 'Failed to freeze package.');
  }

  @override
  Future<UserProfile> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      // Re-fetch profile so the cleared mustChangePassword flag is reflected.
      return getProfile(token);
    }

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['message'] ?? 'Failed to change password.');
  }

  @override
  Future<void> signOut() async {
    await _local.clearSession();
  }
}
