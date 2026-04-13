import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dummy_data.dart';
import '../models/monthly_recovery.dart';
import '../widgets/glass_card.dart';
import '../data/data_providers.dart';
import 'pdf_preview_screen.dart';

class MonthlyDraftsScreen extends ConsumerStatefulWidget {
  final String branchId;
  const MonthlyDraftsScreen({super.key, required this.branchId});

  @override
  ConsumerState<MonthlyDraftsScreen> createState() => _MonthlyDraftsScreenState();
}

class _MonthlyDraftsScreenState extends ConsumerState<MonthlyDraftsScreen> {
  // Current mocked month
  final int _selectedMonth = 4;
  final int _selectedYear = 2026;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    // Filter drafts for current mocked month
    final drafts = appState.monthlyRecoveries.where((m) => m.month == _selectedMonth && m.year == _selectedYear).toList();

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
                    'Monthly Drafts ($_selectedMonth/$_selectedYear)',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final office = appState.offices.firstWhere((o) => o.id == widget.branchId);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => PdfPreviewScreen(
                          office: office,
                          month: _selectedMonth,
                          year: _selectedYear,
                          drafts: drafts,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate Final PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      'EMI Verifications pending for generating report',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Customer')),
                              DataColumn(label: Text('A/C No.')),
                              DataColumn(label: Text('Principal\nDue')),
                              DataColumn(label: Text('Interest')),
                              DataColumn(label: Text('Penal\nInterest')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Edit')),
                            ],
                            rows: drafts.map((draft) => _buildDraftRow(context, ref, draft)).toList(),
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

  DataRow _buildDraftRow(BuildContext context, WidgetRef ref, MonthlyRecovery draft) {
    final appState = ref.read(appStateProvider);
    final loan = appState.loans.firstWhere((l) => l.id == draft.loanId);
    final customer = appState.customers.firstWhere((c) => c.id == loan.customerId);

    return DataRow(
      cells: [
        DataCell(Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(loan.accountNo)),
        DataCell(Text('₹${draft.principalDue.toStringAsFixed(0)}')),
        DataCell(Text('₹${draft.interest.toStringAsFixed(0)}')),
        DataCell(Text('₹${draft.penalInterest.toStringAsFixed(0)}', style: TextStyle(color: draft.penalInterest > 0 ? Colors.red : null))),
        DataCell(Text('₹${draft.totalRecovered.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              _showEditModal(context, ref, draft, customer.name);
            },
          ),
        ),
      ],
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref, MonthlyRecovery draft, String customerName) {
    final penalCtrl = TextEditingController(text: draft.penalInterest.toString());
    final othersCtrl = TextEditingController(text: draft.otherCharges.toString());
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit Recovery: $customerName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: penalCtrl, decoration: const InputDecoration(labelText: 'Penal Interest'), keyboardType: TextInputType.number),
            TextField(controller: othersCtrl, decoration: const InputDecoration(labelText: 'Other Charges'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).updateDraft(
                draft.id, 
                double.tryParse(penalCtrl.text) ?? 0.0,
                double.tryParse(othersCtrl.text) ?? 0.0,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
            child: const Text('Save Draft'),
          ),
        ],
      ),
    );
  }
}
