import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_notifier.dart';

/// Shown (and enforced via router redirect) when a member logs in with a
/// staff-reset temporary password. They cannot leave until they set a new one.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  static const _accent = Color(0xFFFF5B14);

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || next.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (next.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (next != confirm) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final err = await ref.read(authNotifierProvider.notifier).changePassword(
          currentPassword: current,
          newPassword: next,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (err != null) {
      setState(() => _error = err);
    }
    // On success the auth state's mustChangePassword flips to false and the
    // router redirect moves the member into the app automatically.
  }

  @override
  Widget build(BuildContext context) {
    // Forced flow — block the hardware back button.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: _accent, size: 34),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Set a new password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your password was reset by the gym. Please choose a new password to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  _field(_currentController, 'Temporary password', obscure: true),
                  const SizedBox(height: 12),
                  _field(_newController, 'New password', obscure: true),
                  const SizedBox(height: 12),
                  _field(_confirmController, 'Confirm new password', obscure: true),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text('Update password',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => ref.read(authNotifierProvider.notifier).logout(),
                    child: Text('Sign out', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
