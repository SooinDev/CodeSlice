import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final List<BoxShadow>? shadows;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.color,
    this.textColor,
    this.borderRadius = 12,
    this.shadows,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.color != null) return widget.color!;

    switch (widget.style) {
      case AppButtonStyle.primary:
        return const Color(0xFF0969DA);
      case AppButtonStyle.secondary:
        return isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA);
      case AppButtonStyle.outline:
      case AppButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.textColor != null) return widget.textColor!;

    switch (widget.style) {
      case AppButtonStyle.primary:
        return Colors.white;
      case AppButtonStyle.secondary:
        return isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
      case AppButtonStyle.outline:
        return const Color(0xFF0969DA);
      case AppButtonStyle.ghost:
        return isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
    }
  }

  Border? _getBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.style) {
      case AppButtonStyle.primary:
        return null;
      case AppButtonStyle.secondary:
        return Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
          width: 1,
        );
      case AppButtonStyle.outline:
        return Border.all(
          color: const Color(0xFF0969DA),
          width: 1,
        );
      case AppButtonStyle.ghost:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onPressed,
              child: Container(
                width: widget.width,
                height: widget.height ?? 48,
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: _getBorder(context),
                  boxShadow: widget.shadows ?? (widget.style == AppButtonStyle.primary ? [
                    BoxShadow(
                      color: const Color(0xFF0969DA).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: _getTextColor(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}