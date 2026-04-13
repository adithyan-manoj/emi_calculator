import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  final Widget child;

  const DashboardScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Glass sidebar content
    final sidebarContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 40, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.account_balance_outlined,
                  size: 28, color: AppTheme.primary),
              SizedBox(height: 12),
              Text(
                'Co-op Society',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Loan Recovery',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(height: 1, color: AppTheme.divider),
        ),
        const SizedBox(height: 12),
        _SidebarTile(
          icon: CupertinoIcons.person_3,
          label: 'Customers',
          selected: true,
          onTap: () {
            context.go('/');
            if (!isDesktop) Navigator.of(context).pop();
          },
        ),
        _SidebarTile(
          icon: CupertinoIcons.doc_text,
          label: 'Monthly EMI Drafts',
          selected: false,
          onTap: () {
            context.go('/drafts');
            if (!isDesktop) Navigator.of(context).pop();
          },
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // Glass sidebar
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 240,
                  decoration: const BoxDecoration(
                    color: AppTheme.glassWhite,
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.glassBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  child: sidebarContent,
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile: drawer
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Loan Recovery System'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.glassWhite,
              ),
              child: sidebarContent,
            ),
          ),
        ),
      ),
      body: child,
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
