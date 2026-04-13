import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/monthly_recovery.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';
import '../data/data_providers.dart';
import 'pdf_preview_screen.dart';

class MonthlyDraftsScreen extends ConsumerStatefulWidget {
  final String branchId;
  const MonthlyDraftsScreen({super.key, required this.branchId});

  @override
  ConsumerState<MonthlyDraftsScreen> createState() =>
      _MonthlyDraftsScreenState();
}

class _MonthlyDraftsScreenState extends ConsumerState<MonthlyDraftsScreen> {
  int _selectedMonth = 4;
  int _selectedYear = 2026;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider).requireValue;

    // Get all loans that belong to this branch
    final branchLoanIds = appState.loans.where((loan) {
      final customer =
          appState.customers.firstWhere((c) => c.id == loan.customerId);
      return customer.officeId == widget.branchId;
    }).map((loan) => loan.id).toSet();

    // Filter drafts for current month/year AND this branch's loans
    final drafts = appState.monthlyRecoveries
        .where((m) =>
            m.month == _selectedMonth &&
            m.year == _selectedYear &&
            branchLoanIds.contains(m.loanId))
        .toList();

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text('Monthly Drafts · $_selectedMonth/$_selectedYear'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── Data table card ──────────────────────────────
              Expanded(
                child: GlassCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.table_rows_outlined,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EMI Verifications',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 16),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.accent.withOpacity(0.18),
                                    width: 1),
                              ),
                              child: Text(
                                '${drafts.length} records',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                        child: Text(
                          'Pending verifications before generating report',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Divider(height: 1, color: AppTheme.divider),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: DataTable(
                                headingRowColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                dataRowColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                dividerThickness: 0.5,
                                columnSpacing: 18,
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
                                  DataColumn(label: Text('CUSTOMER')),
                                  DataColumn(label: Text('A/C NO.')),
                                  DataColumn(label: Text('PRINCIPAL')),
                                  DataColumn(label: Text('INTEREST')),
                                  DataColumn(label: Text('PENAL')),
                                  DataColumn(label: Text('TOTAL')),
                                  DataColumn(label: Text('EDIT')),
                                ],
                                rows: drafts
                                    .map((draft) =>
                                        _buildDraftRow(context, ref, draft))
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
              const SizedBox(height: 16),
              // ── Action buttons ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.sync_rounded,
                      label: 'Generate Data',
                      filled: false,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(_selectedYear, _selectedMonth),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedMonth = date.month;
                            _selectedYear = date.year;
                          });
                          try {
                            final msg = await ref
                                .read(appStateProvider.notifier)
                                .generateDrafts(date.month, date.year);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to generate: $e'),
                                  backgroundColor: Colors.red.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Generate PDF',
                      filled: true,
                      onTap: () {
                        final office = appState.offices
                            .firstWhere((o) => o.id == widget.branchId);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => PdfPreviewScreen(
                              office: office,
                              month: _selectedMonth,
                              year: _selectedYear,
                              drafts: drafts,
                              customers: appState.customers,
                              loans: appState.loans,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDraftRow(
      BuildContext context, WidgetRef ref, MonthlyRecovery draft) {
    final appState = ref.read(appStateProvider).requireValue;
    final loan = appState.loans.firstWhere((l) => l.id == draft.loanId);
    final customer =
        appState.customers.firstWhere((c) => c.id == loan.customerId);

    return DataRow(
      cells: [
        DataCell(Text(customer.name,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(loan.accountNo)),
        DataCell(Text('₹${draft.principalDue.toStringAsFixed(0)}')),
        DataCell(Text('₹${draft.interest.toStringAsFixed(0)}')),
        DataCell(Text(
          '₹${draft.penalInterest.toStringAsFixed(0)}',
          style: TextStyle(
              color: draft.penalInterest > 0 ? Colors.red.shade400 : null),
        )),
        DataCell(Text(
          '₹${draft.totalRecovered.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        )),
        DataCell(
          GestureDetector(
            onTap: () => _showEditModal(context, ref, draft, customer.name),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.14), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined,
                      size: 13, color: AppTheme.primary),
                  SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref,
      MonthlyRecovery draft, String customerName) {
    final principalCtrl =
        TextEditingController(text: draft.principalDue.toString());
    final interestCtrl =
        TextEditingController(text: draft.interest.toString());
    final penalCtrl =
        TextEditingController(text: draft.penalInterest.toString());
    final othersCtrl =
        TextEditingController(text: draft.otherCharges.toString());

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Recovery',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                _GlassTextField(
                    controller: principalCtrl,
                    label: 'Principal Due',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _GlassTextField(
                    controller: interestCtrl,
                    label: 'Interest',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _GlassTextField(
                    controller: penalCtrl,
                    label: 'Penal Interest',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _GlassTextField(
                    controller: othersCtrl,
                    label: 'Other Charges',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        ref.read(appStateProvider.notifier).updateDraft(
                              draft.id,
                              principalDue:
                                  double.tryParse(principalCtrl.text) ?? 0.0,
                              interest:
                                  double.tryParse(interestCtrl.text) ?? 0.0,
                              penalInt:
                                  double.tryParse(penalCtrl.text) ?? 0.0,
                              others:
                                  double.tryParse(othersCtrl.text) ?? 0.0,
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Draft'),
                    ),
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

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: filled
              ? AppTheme.primary
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : AppTheme.divider,
            width: 1.2,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: filled ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: filled ? Colors.white : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  const _GlassTextField({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
