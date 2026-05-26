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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check-in Confirmed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(result.message),
                const SizedBox(height: 14),
                if (result.branchName != null)
                  Text(
                    result.branchName!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                if (result.remainingSessions != null) ...[
                  const SizedBox(height: 8),
                  Text('Remaining sessions: ${result.remainingSessions}'),
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
