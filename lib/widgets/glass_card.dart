import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/data_providers.dart';
import 'background_scaffold.dart';

/// A high-fidelity liquid-glass card that supports flexible constraints.
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
          alignment: Alignment.center,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

/// A centralized glass-themed error state to be used across screens.
class GlassErrorPlaceholder extends ConsumerWidget {
  final String message;
  final Object? error;
  const GlassErrorPlaceholder({super.key, required this.message, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 48),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verify yours network connection and backend availability.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => ref.invalidate(appStateProvider),
                  child: const SizedBox(
                    height: 50,
                    width: 160,
                    child: GlassPill(
                      child: Text('RETRY', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 32),
                  Text('Debug: $error', style: const TextStyle(color: Colors.white12, fontSize: 9), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A centralized glass-themed loading state.
class GlassLoadingPlaceholder extends StatelessWidget {
  final String message;
  const GlassLoadingPlaceholder({super.key, this.message = 'Loading Core...'});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
              width: 100,
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(message.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
