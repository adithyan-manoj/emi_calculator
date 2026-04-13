import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';

class MonthlyDraftsScreen extends ConsumerStatefulWidget {
  final String branchId;
  const MonthlyDraftsScreen({super.key, required this.branchId});

  @override
  ConsumerState<MonthlyDraftsScreen> createState() => _MonthlyDraftsScreenState();
}

class _MonthlyDraftsScreenState extends ConsumerState<MonthlyDraftsScreen> {
  final int _currentMonth = DateTime.now().month;
  final int _currentYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider).requireValue;
    final office = appState.offices.firstWhere((o) => o.id == widget.branchId);
    
    // Get loans for this branch
    final branchLoanIds = appState.customers
        .where((c) => c.officeId == widget.branchId)
        .expand((c) => appState.loans.where((l) => l.customerId == c.id).map((l) => l.id))
        .toSet();

    // Get drafts for this month and branch
    final drafts = appState.monthlyRecoveries
        .where((d) => d.month == _currentMonth && d.year == _currentYear && branchLoanIds.contains(d.loanId))
        .toList();

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('${office.name} Drafts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (drafts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: SizedBox(
                height: 38,
                child: GestureDetector(
                  onTap: () => context.push('/branch/${widget.branchId}/preview'),
                  child: const GlassPill(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined, size: 14, color: Colors.white),
                        SizedBox(width: 8),
                        Text('PDF PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
                    'Monthly Collection',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  if (drafts.isEmpty)
                    SizedBox(
                      height: 48,
                      child: GestureDetector(
                        onTap: () async {
                          await ref.read(appStateProvider.notifier).generateDrafts(_currentMonth, _currentYear);
                        },
                        child: const GlassPill(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('GENERATE DRAFTS', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Text(
                              'Master Collection: ${DateTime.now().month}/${DateTime.now().year}', 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                            const Spacer(),
                            const Icon(Icons.table_chart_outlined, color: Colors.white30, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Colors.white12),
                      Expanded(
                        child: drafts.isEmpty 
                          ? const Center(child: Text('No recovery drafts generated for this month.', style: TextStyle(color: Colors.white24)))
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(Colors.transparent),
                                    dataRowColor: WidgetStateProperty.all(Colors.transparent),
                                    dividerThickness: 0.5,
                                    horizontalMargin: 12,
                                    columnSpacing: 24,
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: Colors.white38,
                                      letterSpacing: 1,
                                    ),
                                    dataTextStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                    columns: const [
                                      DataColumn(label: Text('MEMBER')),
                                      DataColumn(label: Text('LOAN ACCOUNT')),
                                      DataColumn(label: Text('DUE (₹)')),
                                      DataColumn(label: Text('ADJUST')),
                                    ],
                                    rows: drafts.map((d) {
                                      final loan = appState.loans.firstWhere((l) => l.id == d.loanId);
                                      final customer = appState.customers.firstWhere((c) => c.id == loan.customerId);
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(customer.name.toUpperCase())),
                                          DataCell(Text(loan.accountNo)),
                                          DataCell(Text('₹${d.principalDue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent))),
                                          DataCell(
                                            SizedBox(
                                              height: 32,
                                              width: 75,
                                              child: GestureDetector(
                                                onTap: () => _showEditEmiDialog(context, ref, d.id, loan.accountNo, d.principalDue),
                                                child: const GlassPill(
                                                  padding: EdgeInsets.zero,
                                                  child: Text('EDIT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
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

  void _showEditEmiDialog(BuildContext context, WidgetRef ref, String draftId, String accountNo, double currentAmount) {
    final controller = TextEditingController(text: currentAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => _GlassInputDialog(
        title: 'Adjust Collection',
        subtitle: 'A/C: $accountNo',
        controller: controller,
        onConfirm: () {
          final newValue = double.tryParse(controller.text) ?? currentAmount;
          ref.read(appStateProvider.notifier).updateDraft(draftId, principalDue: newValue);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _GlassInputDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final VoidCallback onConfirm;
  const _GlassInputDialog({required this.title, required this.subtitle, required this.controller, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: IntrinsicHeight(
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Draft Amount (₹)',
                    labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.accent)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontSize: 12))),
                    const SizedBox(width: 16),
                    SizedBox(height: 44, width: 110, child: GestureDetector(onTap: onConfirm, child: const GlassPill(child: Text('UPDATE', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11))))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
