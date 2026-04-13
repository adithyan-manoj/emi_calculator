import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../models/customer.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = DummyData.customers;

    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Customers Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Customers',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 28),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              size: 17, color: Colors.white),
                          SizedBox(width: 6),
                          Text('New Customer',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 20, 20, 14),
                        child: Text(
                          'All Registered Customers',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 16),
                        ),
                      ),
                      const Divider(height: 1, color: AppTheme.divider),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                    Colors.transparent),
                                dataRowColor: WidgetStateProperty.all(
                                    Colors.transparent),
                                dividerThickness: 0.5,
                                headingTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.4,
                                ),
                                dataTextStyle: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                                columns: const [
                                  DataColumn(label: Text('MEMBER NO.')),
                                  DataColumn(label: Text('NAME')),
                                  DataColumn(label: Text('OFFICE')),
                                  DataColumn(label: Text('ACTION')),
                                ],
                                rows: customers
                                    .map((c) =>
                                        _buildCustomerRow(context, c))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildCustomerRow(BuildContext context, Customer customer) {
    final officeName = DummyData.offices
        .firstWhere((o) => o.id == customer.officeId)
        .name;

    return DataRow(cells: [
      DataCell(Text(customer.memberNo)),
      DataCell(Text(customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(officeName)),
      DataCell(
        GestureDetector(
          onTap: () => context.go('/customer/${customer.id}'),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  width: 1),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary),
            ),
          ),
        ),
      ),
    ]);
  }
}
