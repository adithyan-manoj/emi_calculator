import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class CustomerProfileScreen extends ConsumerWidget {
  final String customerId;

  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider).requireValue;
    final customer = appState.customers.firstWhere((c) => c.id == customerId);
    final office = appState.offices.firstWhere((o) => o.id == customer.officeId);
    final loans = appState.loans.where((l) => l.customerId == customerId).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Customer Profile',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text('Member No: ${customer.memberNo}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text('Office: ${office.name}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Active Loans',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loans.isEmpty
                  ? const Center(child: Text('No active loans found.'))
                  : ListView.builder(
                      itemCount: loans.length,
                      itemBuilder: (context, index) {
                        final loan = loans[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Account No: ${loan.accountNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text('Status: ${loan.status}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('Principal O/S: ₹${loan.principalOutstanding}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 8),
                                          Text('Base EMI: ₹${loan.baseEmiAmount}', style: const TextStyle(color: AppTheme.primary)),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: AppTheme.surface,
                                              title: const Text('Delete Loan?'),
                                              content: const Text('Are you sure you want to delete this loan account?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                  onPressed: () {
                                                    ref.read(appStateProvider.notifier).deleteLoan(loan.id);
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            )
                                          );
                                        },
                                      ),
                                    ],
                                  ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLoanModal(context, ref),
        label: const Text('Add Loan', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _showAddLoanModal(BuildContext context, WidgetRef ref) {
    final acCtrl = TextEditingController();
    final osCtrl = TextEditingController();
    final emiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Create Loan Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: acCtrl, decoration: const InputDecoration(labelText: 'Account No. (e.g. 12/25-26)')),
            TextField(controller: osCtrl, decoration: const InputDecoration(labelText: 'Principal Outstanding'), keyboardType: TextInputType.number),
            TextField(controller: emiCtrl, decoration: const InputDecoration(labelText: 'Base EMI Amount'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).addLoan(
                customerId, acCtrl.text, 
                double.tryParse(osCtrl.text) ?? 0, 
                double.tryParse(emiCtrl.text) ?? 0
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
