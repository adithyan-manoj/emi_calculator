import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../models/customer.dart';
import '../widgets/glass_card.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = DummyData.customers;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Text(
                  'Customers Overview',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO Add new customer dummy form
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'All Registered Customers',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Member No.')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Office')),
                              DataColumn(label: Text('Action')),
                            ],
                            rows: customers.map((c) => _buildCustomerRow(context, c)).toList(),
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
    );
  }

  DataRow _buildCustomerRow(BuildContext context, Customer customer) {
    final officeName = DummyData.offices.firstWhere((o) => o.id == customer.officeId).name;
    
    return DataRow(
      cells: [
        DataCell(Text(customer.memberNo)),
        DataCell(Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(officeName)),
        DataCell(
          TextButton(
            onPressed: () {
              context.go('/customer/${customer.id}');
            },
            child: const Text('View Profile'),
          ),
        ),
      ],
    );
  }
}
