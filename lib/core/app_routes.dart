import 'package:flutter/material.dart';

abstract final class AppRoutes {
  /// Fade transition; keeps [Hero] flights smooth.
  static Route<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
}
