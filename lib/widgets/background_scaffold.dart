import 'package:flutter/material.dart';

/// Wraps any screen with the abstract image background so that
/// the liquid-glass cards appear to float above the texture.
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
      backgroundColor: backgroundColor ?? Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/abstract_bg.png',
            fit: BoxFit.cover,
          ),
          // Slight off-white overlay to keep readability
          ColoredBox(
            color: const Color(0x55F4F3EF),
          ),
          // Actual screen content
          child,
        ],
      ),
    );
  }
}
