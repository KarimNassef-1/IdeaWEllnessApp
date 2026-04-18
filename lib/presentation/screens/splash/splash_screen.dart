import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../state/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minSplash = Duration(milliseconds: 1400);
  static const _maxSplash = Duration(milliseconds: 2400);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final startedAt = DateTime.now();

    await Future<void>.delayed(_minSplash);

    while (mounted) {
      final auth = ref.read(authNotifierProvider);
      final elapsed = DateTime.now().difference(startedAt);
      if (!auth.loading || elapsed >= _maxSplash) break;
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    if (!mounted) return;

    final auth = ref.read(authNotifierProvider);
    context.go(auth.isAuthenticated ? AppRoutes.shell : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'img/idea-app-icon.png',
            width: 92,
            height: 92,
          ),
        ),
      ),
    );
  }
}
