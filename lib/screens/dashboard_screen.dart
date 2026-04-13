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

    final sidebarMenu = Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Co-op Society',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(CupertinoIcons.person_3),
          title: const Text('Customers'),
          selected: true,
          selectedColor: AppTheme.primary,
          onTap: () {
            context.go('/');
            if (!isDesktop) Navigator.of(context).pop(); // Close drawer
          },
        ),
        ListTile(
          leading: const Icon(CupertinoIcons.doc_text),
          title: const Text('Monthly EMI Drafts'),
          onTap: () {
            context.go('/drafts');
            if (!isDesktop) Navigator.of(context).pop(); // Close drawer
          },
        ),
      ],
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  right: BorderSide(
                    color: AppTheme.textSecondary.withOpacity(0.1),
                  ),
                ),
              ),
              child: sidebarMenu,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Recovery System'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: Container(
          color: AppTheme.surface,
          child: sidebarMenu,
        ),
      ),
      body: child,
    );
  }
}
