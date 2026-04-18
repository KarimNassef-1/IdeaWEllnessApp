import 'package:flutter/material.dart';

class BottomSheetModal {
  const BottomSheetModal._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, value, animatedChild) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 28),
              child: Opacity(opacity: value.clamp(0, 1), child: animatedChild),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
