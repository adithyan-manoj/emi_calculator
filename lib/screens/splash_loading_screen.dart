import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';

class SplashLoadingScreen extends StatelessWidget {
  final String message;
  const SplashLoadingScreen({super.key, this.message = 'Synchronizing...'});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security_rounded, size: 40, color: Colors.white),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white.withValues(alpha: 0.8),
                            backgroundColor: Colors.white10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                message.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'SAFE · SECURE · RELIABLE',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
