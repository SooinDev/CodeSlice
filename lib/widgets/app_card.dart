import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;
  final bool enableBlur;
  final bool enableHoverEffect;
  final Duration animationDuration;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.shadows,
    this.border,
    this.enableBlur = false,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enableHoverEffect) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableHoverEffect) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.color ??
                (isDark ? const Color(0xFF21262D) : Colors.white),
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
              border: widget.border ?? Border.all(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFE1E4E8),
                width: 1,
              ),
              boxShadow: widget.enableHoverEffect
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.black12)
                          .withOpacity(0.1 * _shadowAnimation.value),
                      blurRadius: 8 * _shadowAnimation.value,
                      offset: Offset(0, 4 * _shadowAnimation.value),
                    ),
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.black12)
                          .withOpacity(0.05 * _shadowAnimation.value),
                      blurRadius: 16 * _shadowAnimation.value,
                      offset: Offset(0, 8 * _shadowAnimation.value),
                    ),
                  ]
                : widget.shadows,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                onTap: widget.onTap,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}