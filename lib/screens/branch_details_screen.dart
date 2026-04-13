import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class BranchDetailsScreen extends ConsumerWidget {
  final String branchId;
  const BranchDetailsScreen({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider).requireValue;
    final office = appState.offices.firstWhere((o) => o.id == branchId);
    final customers = appState.customers.where((c) => c.officeId == branchId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(office.name),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.push('/branch/$branchId/drafts');
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Review Month Draft'),
          ),
          const SizedBox(width: 16),
        ],
      ),
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
                  'Employees',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEmployeeModal(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Employee'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  // Calculate dummy stats for this customer
                  final customerLoans = appState.loans.where((l) => l.customerId == customer.id).toList();
                  final totalOs = customerLoans.fold(0.0, (sum, l) => sum + l.principalOutstanding);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer.name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Text('Member No: ${customer.memberNo}', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () => context.push('/customer/${customer.id}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primary,
                                  elevation: 0,
                                ),
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStat('Active Loans', '${customerLoans.length}'),
                              _buildStat('Total Outstanding', '₹${totalOs.toStringAsFixed(0)}'),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  void _showAddEmployeeModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final memberCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Add New Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Employee Name')),
            const SizedBox(height: 8),
            TextField(controller: memberCtrl, decoration: const InputDecoration(labelText: 'Member No.')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).addEmployee(branchId, nameCtrl.text, memberCtrl.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Save Employee'),
          ),
        ],
      ),
    );
  }
}
