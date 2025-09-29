import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);

  // Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  // Apple-style curves
  static const Curve appleEaseIn = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve appleEaseOut = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve appleEaseInOut = Cubic(0.4, 0.0, 0.2, 1.0);

  // Page transitions
  static SlideTransition slideTransition(
    Animation<double> animation,
    Widget child, {
    Offset? begin,
    Offset? end,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin ?? const Offset(1.0, 0.0),
        end: end ?? Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: appleEaseOut,
      )),
      child: child,
    );
  }

  static FadeTransition fadeTransition(
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget scaleTransition(
    Animation<double> animation,
    Widget child, {
    double? begin,
    double? end,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin ?? 0.0,
        end: end ?? 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: appleEaseOut,
      )),
      child: child,
    );
  }

  // Staggered animations
  static Animation<double> createStaggeredAnimation({
    required AnimationController controller,
    required double delay,
    required double duration,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay,
        delay + duration,
        curve: curve,
      ),
    ));
  }

  // Bounce animation
  static Animation<double> createBounceAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  // Shimmer animation
  static Widget shimmerEffect({
    required Widget child,
    required bool isLoading,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return AnimatedSwitcher(
      duration: medium,
      child: isLoading
        ? _ShimmerWidget(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: child,
          )
        : child,
    );
  }

  // Custom page route with Apple-style transition
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = appleEaseOut,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerWidget({
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ??
        (isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA));
    final highlightColor = widget.highlightColor ??
        (isDark ? const Color(0xFF30363D) : const Color(0xFFE1E4E8));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}