import 'package:flutter/material.dart';

class SlideFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Offset begin;

  const SlideFadeTransition({
    super.key,
    required this.child,
    required this.animation,
    this.begin = const Offset(0, 0.3),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              begin.dx * (1 - animation.value) * 100,
              begin.dy * (1 - animation.value) * 100,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ScaleFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const ScaleFadeTransition({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * animation.value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

PageRouteBuilder<T> buildSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

PageRouteBuilder<T> buildFadeScaleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

PageRouteBuilder<T> buildFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
