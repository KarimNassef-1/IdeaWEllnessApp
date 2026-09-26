import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../state/auth_notifier.dart';
import '../../widgets/gradient_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final first = _firstName.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    if (first.isEmpty || email.isEmpty || password.isEmpty) {
      _snack('Please fill in your name, email, and password.');
      return;
    }
    if (password.length < 6) {
      _snack('Password must be at least 6 characters.');
      return;
    }

    final error = await ref.read(authNotifierProvider.notifier).register(
          firstName: first,
          lastName: _lastName.text.trim(),
          email: email,
          password: password,
          phoneNumber: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        );

    if (!mounted || error == null) return; // success → router redirects home
    _snack(error);
  }

  // Google sign-up is temporarily hidden until OAuth verification is finished.
  // Re-enable by restoring the "Continue with Google" button and this handler.
  // Future<void> _google() async {
  //   final error = await ref.read(authNotifierProvider.notifier).googleSignIn();
  //   if (!mounted || error == null) return;
  //   _snack(error);
  // }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7F3EE), Color(0xFFF2EEE7), Color(0xFFEDE6DE)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withValues(alpha: 0.88),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('img/idea-app-icon.png', width: 72, height: 72),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Join IDEA Wellness',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5D5D5D),
                              ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(child: _field(_firstName, 'First name', Icons.person_rounded, scheme)),
                            const SizedBox(width: 12),
                            Expanded(child: _field(_lastName, 'Last name', Icons.person_outline_rounded, scheme)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _field(_email, 'Email', Icons.email_rounded, scheme,
                            keyboard: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _field(_phone, 'Phone (optional)', Icons.phone_rounded, scheme,
                            keyboard: TextInputType.phone),
                        const SizedBox(height: 14),
                        _field(_password, 'Password', Icons.lock_rounded, scheme,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            )),
                        const SizedBox(height: 20),
                        if (authState.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          GradientButton(
                            label: 'Create account',
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: _register,
                          ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text('Already have an account? Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon,
    ColorScheme scheme, {
    TextInputType? keyboard,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        floatingLabelStyle: TextStyle(color: scheme.primary),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
