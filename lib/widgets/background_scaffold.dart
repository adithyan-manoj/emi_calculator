import 'package:flutter/material.dart';

/// Wraps any screen with the atmospheric forest background.
/// Darkened with a subtle glass overlay for high contrast with white glass cards.
class BackgroundScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const BackgroundScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.black,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Forest background image
          Image.asset(
            'assets/atmospheric_nature_bg.png',
            fit: BoxFit.cover,
          ),
          // Dark glass tint overlay
          const ColoredBox(
            color: Color(0x33000000), // Very light dark tint
          ),
          // Actual screen content
          child,
        ],
      ),
    );
  }
}
