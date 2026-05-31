import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../domain/entities/branch_summary.dart';
import '../../domain/entities/class_schedule_item.dart';
import '../../domain/entities/subscribed_class.dart';

class DashboardRepository {
  Future<List<BranchSummary>> branches(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/dashboard/branches'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load branches.');
    }

    return (jsonDecode(response.body) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(BranchSummary.fromJson)
        .toList();
  }

  Future<List<SubscribedClass>> subscribedClasses(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/dashboard/subscribed-classes'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load subscribed classes.');
    }

    return (jsonDecode(response.body) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(SubscribedClass.fromJson)
        .toList();
  }

  Future<TodayClasses> todayClasses(String token, {String? branchId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/dashboard/today-classes')
        .replace(queryParameters: branchId != null ? {'branchId': branchId} : null);

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode != 200) {
      throw Exception('Failed to load today\'s classes.');
    }

    return TodayClasses.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    };
  }
}
