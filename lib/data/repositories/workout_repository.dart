import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/network/session_expiry.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_plan.dart';

class WorkoutRepository {
  static String get _base => '${ApiConfig.baseUrl}/api/workout';

  // ── Exercise Library ───────────────────────────────────────────────────────

  Future<List<ExerciseCategory>> categories(String token) async {
    final res = await http.get(Uri.parse('$_base/categories'), headers: _h(token));
    _check(res, 'categories');
    return (jsonDecode(res.body) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(ExerciseCategory.fromJson)
        .toList();
  }

  Future<List<ExerciseListItem>> exercises(
    String token, {
    int? categoryId,
    String? search,
  }) async {
    final uri = Uri.parse('$_base/exercises').replace(queryParameters: {
      if (categoryId != null) 'categoryId': '$categoryId',
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final res = await http.get(uri, headers: _h(token));
    _check(res, 'exercises');
    return (jsonDecode(res.body) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(ExerciseListItem.fromJson)
        .toList();
  }

  Future<ExerciseDetail> exerciseDetail(String token, String exerciseId) async {
    final res = await http.get(
      Uri.parse('$_base/exercises/$exerciseId'),
      headers: _h(token),
    );
    _check(res, 'exercise detail');
    return ExerciseDetail.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Workout Plans ──────────────────────────────────────────────────────────

  Future<List<WorkoutPlanListItem>> myPlans(String token) async {
    final res = await http.get(Uri.parse('$_base/plans'), headers: _h(token));
    _check(res, 'plans');
    return (jsonDecode(res.body) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(WorkoutPlanListItem.fromJson)
        .toList();
  }

  Future<WorkoutPlanDetail> planDetail(String token, String planId) async {
    final res = await http.get(Uri.parse('$_base/plans/$planId'), headers: _h(token));
    _check(res, 'plan detail');
    return WorkoutPlanDetail.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<WorkoutPlanListItem> createPlan(
    String token, {
    required String planName,
    int? dayOfWeek,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/plans'),
      headers: _h(token),
      body: jsonEncode({'planName': planName, 'dayOfWeek': dayOfWeek}),
    );
    _check(res, 'create plan');
    return WorkoutPlanListItem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deletePlan(String token, String planId) async {
    final res = await http.delete(Uri.parse('$_base/plans/$planId'), headers: _h(token));
    throwIfUnauthorized(res.statusCode);
    if (res.statusCode != 204) throw Exception('Failed to delete plan.');
  }

  Future<void> addExerciseToPlan(
    String token, {
    required String planId,
    required String exerciseId,
    int? sets,
    int? reps,
    int? durationSeconds,
    int? restSeconds,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/plans/$planId/exercises'),
      headers: _h(token),
      body: jsonEncode({
        'exerciseId': exerciseId,
        'sets': ?sets,
        'reps': ?reps,
        'durationSeconds': ?durationSeconds,
        'restSeconds': ?restSeconds,
      }),
    );
    _check(res, 'add exercise');
  }

  Future<void> updatePlanExercise(
    String token, {
    required String planId,
    required String entryId,
    int? sets,
    int? reps,
    int? durationSeconds,
    int? restSeconds,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/plans/$planId/exercises/$entryId'),
      headers: _h(token),
      body: jsonEncode({
        'sets': sets,
        'reps': reps,
        'durationSeconds': durationSeconds,
        'restSeconds': restSeconds,
      }),
    );
    throwIfUnauthorized(res.statusCode);
    if (res.statusCode != 204) throw Exception('Failed to update exercise.');
  }

  Future<void> removeExerciseFromPlan(
    String token, {
    required String planId,
    required String entryId,
  }) async {
    final res = await http.delete(
      Uri.parse('$_base/plans/$planId/exercises/$entryId'),
      headers: _h(token),
    );
    throwIfUnauthorized(res.statusCode);
    if (res.statusCode != 204) throw Exception('Failed to remove exercise.');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, String> _h(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      };

  void _check(http.Response res, String label) {
    throwIfUnauthorized(res.statusCode);
    if (res.statusCode != 200) throw Exception('Failed to load $label.');
  }
}
