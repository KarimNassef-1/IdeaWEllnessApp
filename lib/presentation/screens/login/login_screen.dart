import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/gradient_button.dart';
import '../../state/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _gymIdController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _gymIdController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final success = await ref.read(authNotifierProvider.notifier).login(
          username: _usernameController.text,
          gymId: _gymIdController.text,
        );

    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter username and gym ID.')),
    );
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
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x55F7931A), Color(0x00F7931A)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x33FFBE7A), Color(0x00FFBE7A)],
                ),
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
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('img/idea-app-icon.png', width: 88, height: 88),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Idea Wellness',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Premium access to your gym ecosystem',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5D5D5D),
                              ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_rounded),
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
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _gymIdController,
                          onSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Gym ID',
                            prefixIcon: const Icon(Icons.badge_rounded),
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
                        ),
                        const SizedBox(height: 18),
                        if (authState.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(),
                          )
                        else
                          GradientButton(
                            label: 'Login',
                            icon: Icons.login_rounded,
                            onPressed: _login,
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
}
