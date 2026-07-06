import 'package:flutter/material.dart';

import '../../../data/repositories/attendance_repository.dart';

class QrSessionConfirmationScreen extends StatelessWidget {
  const QrSessionConfirmationScreen({super.key, required this.result});

  final AttendanceCheckInResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Session Confirmation'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success check icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF16A34A),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Check-in Confirmed',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 14),
                if (result.branchName != null)
                  Text(
                    result.branchName!,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                if (result.remainingSessions != null) ...[
                  const SizedBox(height: 14),
                  // Prominent "classes left" alert after a class attendance.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF8F3), Color(0xFFFFE9D6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF5B14), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${result.remainingSessions}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF5B14),
                            fontSize: 30,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result.isClassAttendance
                                ? (result.remainingSessions == 1
                                    ? 'class left on your package'
                                    : 'classes left on your package')
                                : (result.remainingSessions == 1
                                    ? 'session remaining'
                                    : 'sessions remaining'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context)
                      ..pop()
                      ..pop(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
