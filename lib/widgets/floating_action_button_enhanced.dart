import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_animations.dart';

class FloatingActionButtonEnhanced extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? highlightElevation;
  final ShapeBorder? shape;
  final bool mini;
  final String? tooltip;
  final String? heroTag;
  final bool enablePulse;

  const FloatingActionButtonEnhanced({
    super.key,
    this.onPressed,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.highlightElevation,
    this.shape,
    this.mini = false,
    this.tooltip,
    this.heroTag,
    this.enablePulse = false,
  });

  @override
  State<FloatingActionButtonEnhanced> createState() =>
      _FloatingActionButtonEnhancedState();
}

class _FloatingActionButtonEnhancedState
    extends State<FloatingActionButtonEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.appleEaseOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.enablePulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FloatingActionButtonEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulse != oldWidget.enablePulse) {
      if (widget.enablePulse) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _scaleController.forward();
      _rotationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
      _rotationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
      _rotationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enablePulse
              ? _scaleAnimation.value * _pulseAnimation.value
              : _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppColors.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: widget.elevation ?? 8,
                    offset: Offset(0, (widget.elevation ?? 8) / 2),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppColors.primary)
                          .withValues(alpha: 0.4),
                      blurRadius: (widget.highlightElevation ?? 12),
                      offset: Offset(0, (widget.highlightElevation ?? 12) / 2),
                    ),
                ],
              ),
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onPressed,
                child: FloatingActionButton(
                  onPressed: null, // Handled by gesture detector
                  backgroundColor: widget.backgroundColor ??
                      AppColors.primary,
                  foregroundColor: widget.foregroundColor ??
                      Colors.white,
                  elevation: 0, // Custom shadow handled above
                  highlightElevation: 0,
                  shape: widget.shape ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          widget.mini ? 16 : 28,
                        ),
                      ),
                  mini: widget.mini,
                  tooltip: widget.tooltip,
                  heroTag: widget.heroTag,
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