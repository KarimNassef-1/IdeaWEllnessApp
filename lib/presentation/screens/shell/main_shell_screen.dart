import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/rewards_screen.dart';
import '../workout/workout_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;
  late final PageController _pageController;

  final _screens = const [
    HomeScreen(),
    RewardsScreen(),
    WorkoutScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int newIndex) {
    if (newIndex == _index) return;
    final distance = (newIndex - _index).abs();
    setState(() => _index = newIndex);

    // Long sweeps can stutter while building intermediate pages,
    // so animate only neighboring tabs and jump for distant targets.
    if (distance == 1) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _pageController.jumpToPage(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) => setState(() => _index = value),
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 58,
        height: 58,
        child: FloatingActionButton(
          heroTag: 'qrFab',
          backgroundColor: const Color(0xFFF7931A),
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          splashColor: Colors.white.withValues(alpha: 0.12),
          shape: const CircleBorder(),
          onPressed: () => context.push(AppRoutes.qrScanner),
          child: const Icon(Icons.qr_code_scanner_rounded, size: 24),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomAppBar(
          color: scheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 4,
          child: SizedBox(
            height: 76,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: _index == 0,
                    onTap: () => _goToTab(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.stars_rounded,
                    label: 'Rewards',
                    selected: _index == 1,
                    onTap: () => _goToTab(1),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: _NavItem(
                    icon: Icons.fitness_center_rounded,
                    label: 'Workout',
                    selected: _index == 2,
                    onTap: () => _goToTab(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    selected: _index == 3,
                    onTap: () => _goToTab(3),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
