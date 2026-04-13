import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/branch_details_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/monthly_drafts_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/branch/:id',
      builder: (context, state) => BranchDetailsScreen(
        branchId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/customer/:id',
      builder: (context, state) => CustomerProfileScreen(
        customerId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/branch/:id/drafts',
      builder: (context, state) => MonthlyDraftsScreen(
        branchId: state.pathParameters['id']!,
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Loan Recovery System',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
