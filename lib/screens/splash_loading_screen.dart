import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
          child: GlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 52),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.18),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    size: 36,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Co-op Loan Recovery',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 22,
                        color: AppTheme.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    strokeWidth: 2.5,
                    backgroundColor: AppTheme.accent.withOpacity(0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
