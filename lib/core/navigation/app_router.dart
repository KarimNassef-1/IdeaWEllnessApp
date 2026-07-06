import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/gym_session.dart';
import '../../presentation/screens/beyond/article_screen.dart';
import '../../presentation/screens/workout/exercise_detail_screen.dart';
import '../../presentation/screens/workout/exercise_picker_screen.dart';
import '../../presentation/screens/workout/plan_detail_screen.dart';
import '../../presentation/screens/common/view_all_screen.dart';
import '../../presentation/screens/auth/change_password_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/partner/partner_detail_screen.dart';
import '../../presentation/screens/qr/qr_scanner_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/shell/main_shell_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/state/auth_notifier.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shell,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: const MainShellScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: const QrScannerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.viewAll,
        pageBuilder: (context, state) {
          final payload = state.extra as Map<String, dynamic>?;
          final sessionsRaw = payload?['sessions'] as List<dynamic>? ?? const [];

          return _animatedPage(
            state: state,
            child: ViewAllScreen(
              title: payload?['title'] as String? ?? 'View All',
              items: (payload?['items'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())
                  .toList(),
              mode: payload?['mode'] as String?,
              sessions: sessionsRaw
                  .whereType<Map>()
                  .map((e) => GymSession.fromMap(Map<String, dynamic>.from(e)))
                  .toList(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.article,
        pageBuilder: (context, state) {
          final payload = state.extra as Map<String, dynamic>?;
          return _animatedPage(
            state: state,
            child: ArticleScreen(
              title: payload?['title'] as String? ?? 'Article',
              subtitle: payload?['subtitle'] as String? ?? '',
              image: payload?['image'] as String? ?? 'img/idea-profile.png',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.partnerDetail,
        pageBuilder: (context, state) {
          final payload = state.extra as Map<String, dynamic>?;
          return _animatedPage(
            state: state,
            child: PartnerDetailScreen(
              name: payload?['name'] as String? ?? 'Partner',
              image: payload?['image'] as String? ?? 'img/idea-profile.png',
              url: payload?['url'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: ExerciseDetailScreen(
            exerciseId: state.extra as String,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.workoutPlanDetail,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: PlanDetailScreen(
            planId: state.extra as String,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.exerciseLibraryPicker,
        pageBuilder: (context, state) => _animatedPage(
          state: state,
          child: ExercisePickerScreen(
            planId: state.extra as String,
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;
      final isChangePwRoute = state.matchedLocation == AppRoutes.changePassword;

      if (isSplashRoute) return null;

      if (!auth.isAuthenticated && !isLoginRoute) return AppRoutes.login;

      // Force the temp-password change before anything else once authenticated.
      final mustChange = auth.user?.mustChangePassword ?? false;
      if (auth.isAuthenticated && mustChange && !isChangePwRoute) {
        return AppRoutes.changePassword;
      }
      if (auth.isAuthenticated && !mustChange && isChangePwRoute) {
        return AppRoutes.shell;
      }

      if (auth.isAuthenticated && isLoginRoute) {
        return mustChange ? AppRoutes.changePassword : AppRoutes.shell;
      }
      return null;
    },
  );

  ref.listen(authNotifierProvider, (previous, next) => router.refresh());
  return router;
});

CustomTransitionPage<void> _animatedPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 540),
    reverseTransitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final primary = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final incomingSlide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(primary);
      final incomingFade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.05, 1, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      );

      return Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = primary.value;
              return IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FractionalTranslation(
                      translation: Offset((1 - t) * 0.2, 0),
                      child: Container(color: Colors.black.withValues(alpha: (1 - t) * 0.08)),
                    ),
                    FractionalTranslation(
                      translation: Offset((1 - t) * 0.45, 0),
                      child: Container(color: Colors.black.withValues(alpha: (1 - t) * 0.14)),
                    ),
                  ],
                ),
              );
            },
          ),
          FadeTransition(
            opacity: incomingFade,
            child: SlideTransition(
              position: incomingSlide,
              child: child,
            ),
          ),
        ],
      );
    },
  );
}
