import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/theme_notifier.dart';

class GlobalThemeToggle extends ConsumerStatefulWidget {
  const GlobalThemeToggle({super.key});

  @override
  ConsumerState<GlobalThemeToggle> createState() => _GlobalThemeToggleState();
}

class _GlobalThemeToggleState extends ConsumerState<GlobalThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final isDark = ref.read(themeModeProvider) == ThemeMode.dark;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
      value: isDark ? 1 : 0,
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final target = isDark ? 1.0 : 0.0;

    if ((_controller.value - target).abs() > 0.001) {
      _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 560),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.only(top: 6, right: 8),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 2, right: 2),
          child: RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  splashRadius: 15,
                  icon: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) {
                      final t = _progress.value;
                      final sunOpacity = (1 - t).clamp(0.0, 1.0);
                      final moonOpacity = t.clamp(0.0, 1.0);

                      return SizedBox(
                        width: 16,
                        height: 16,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.translate(
                              offset: Offset(0, -0.8 * t),
                              child: Opacity(
                                opacity: sunOpacity,
                                child: Transform.rotate(
                                  angle: t * 0.72,
                                  child: Transform.scale(
                                    scale: 0.88 + (sunOpacity * 0.12),
                                    child: Icon(
                                      Icons.wb_sunny_rounded,
                                      size: 15,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(0, 0.8 * (1 - t)),
                              child: Opacity(
                                opacity: moonOpacity,
                                child: Transform.rotate(
                                  angle: (1 - t) * -0.72,
                                  child: Transform.scale(
                                    scale: 0.88 + (moonOpacity * 0.12),
                                    child: Icon(
                                      Icons.nightlight_round,
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
