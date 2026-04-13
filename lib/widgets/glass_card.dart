import 'dart:ui';
import 'package:flutter/material.dart';

/// A high-fidelity liquid-glass card that supports flexible constraints.
/// Replaces GlassmorphicContainer to fix IntrinsicHeight layout errors while
/// maintaining the premium liquid glass aesthetic.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double borderOpacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 24,
    this.blur = 20,
    this.borderOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              width: 1.5,
              color: Colors.white.withValues(alpha: borderOpacity),
            ),
            // Layered background for the "liquid" feel
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A smaller, nested glass pill for items and buttons.
class GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassPill({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              width: 1.2,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child: child,
        ),
      ),
    );
  }
}
