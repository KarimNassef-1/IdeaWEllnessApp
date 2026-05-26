import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class AttendanceRepository {
  Future<AttendanceCheckInResult> checkIn({
    required String token,
    required String qrCodeValue,
    AttendancePackageOption? option,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/attendance/check-in'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'qrCodeValue': qrCodeValue,
        if (option != null) 'attendanceMode': option.attendanceMode,
        if (option != null) 'memberPackageId': option.memberPackageId,
      }),
    );

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    final result = AttendanceCheckInResult.fromJson(body);

    if (response.statusCode == 200 || response.statusCode == 409) {
      return result;
    }

    if (response.statusCode == 401) {
      throw Exception('Please log in again.');
    }

    throw Exception(
      result.message.isEmpty ? 'Check-in failed.' : result.message,
    );
  }
}

class AttendanceCheckInResult {
  const AttendanceCheckInResult({
    required this.success,
    required this.requiresChoice,
    required this.message,
    required this.options,
    this.attendanceRecordId,
    this.branchName,
    this.checkInAtUtc,
    this.remainingSessions,
  });

  final bool success;
  final bool requiresChoice;
  final String message;
  final String? attendanceRecordId;
  final String? branchName;
  final String? checkInAtUtc;
  final int? remainingSessions;
  final List<AttendancePackageOption> options;

  factory AttendanceCheckInResult.fromJson(Map<String, dynamic> json) {
    return AttendanceCheckInResult(
      success: json['success'] as bool? ?? false,
      requiresChoice: json['requiresChoice'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      attendanceRecordId: json['attendanceRecordId'] as String?,
      branchName: json['branchName'] as String?,
      checkInAtUtc: json['checkInAtUtc'] as String?,
      remainingSessions: json['remainingSessions'] as int?,
      options: (json['options'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AttendancePackageOption.fromJson)
          .toList(),
    );
  }
}

class AttendancePackageOption {
  const AttendancePackageOption({
    required this.memberPackageId,
    required this.packageName,
    required this.attendanceMode,
    this.remainingSessions,
  });

  final String memberPackageId;
  final String packageName;
  final String attendanceMode;
  final int? remainingSessions;

  String get label => attendanceMode == 'openGym' ? 'Open gym' : 'Class';

  factory AttendancePackageOption.fromJson(Map<String, dynamic> json) {
    return AttendancePackageOption(
      memberPackageId: json['memberPackageId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? 'Package',
      attendanceMode: json['attendanceMode'] as String? ?? 'class',
      remainingSessions: json['remainingSessions'] as int?,
    );
  }
}
