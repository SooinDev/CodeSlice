import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final Widget? icon;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.icon,
    this.actions,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark
          ? const Color(0xFF0D1117)
          : const Color(0xFFFAFBFC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0969DA).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0969DA).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: icon,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 24),
          ],

          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .slideX(begin: -0.2, end: 0),

          const SizedBox(height: 12),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0969DA),
              height: 1.4,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideX(begin: -0.2, end: 0),

          if (description != null) ...[
            const SizedBox(height: 16),
            Text(
              description!,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                height: 1.5,
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .slideX(begin: -0.2, end: 0),
          ],

          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions!
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return action.animate()
                      .fadeIn(duration: 600.ms, delay: (400 + index * 100).ms)
                      .slideY(begin: 0.3, end: 0);
                  })
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}