import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.showShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool showShadow;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.32)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: _pressed ? 8 : 16,
                    spreadRadius: _pressed ? 0 : 1,
                    offset: Offset(0, _pressed ? 2 : 8),
                  ),
                ]
              : null,
        ),
        transform: Matrix4.identity()
          ..scaleByDouble(_pressed ? 0.985 : 1, _pressed ? 0.985 : 1, 1, 1)
          ..translateByDouble(0.0, _pressed ? 1.0 : 0.0, 0, 1),
        child: widget.child,
      ),
    );
  }
}
