import 'package:flutter/material.dart';

class PulseEffect extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double minOpacity;
  final double maxOpacity;
  final Duration duration;
  final bool enabled;

  const PulseEffect({
    super.key,
    required this.child,
    this.color,
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
    this.duration = const Duration(milliseconds: 1000),
    this.enabled = true,
  });

  @override
  State<PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

class RippleEffect extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final Duration duration;
  final VoidCallback? onTap;

  const RippleEffect({
    super.key,
    required this.child,
    this.color,
    this.radius = 100,
    this.duration = const Duration(milliseconds: 300),
    this.onTap,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _radiusAnimation = Tween<double>(
      begin: 0,
      end: widget.radius,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward().then((_) {
      _controller.reset();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_tapPosition != null)
            Positioned(
              left: _tapPosition!.dx - widget.radius,
              top: _tapPosition!.dy - widget.radius,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: _radiusAnimation.value * 2,
                    height: _radiusAnimation.value * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (widget.color ?? Theme.of(context).primaryColor)
                          .withValues(alpha: _opacityAnimation.value),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}