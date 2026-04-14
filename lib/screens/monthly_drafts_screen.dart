import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/data_providers.dart';
import '../models/monthly_recovery.dart';
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
    final appStateAsync = ref.watch(appStateProvider);

    return appStateAsync.when(
      loading: () => const GlassLoadingPlaceholder(message: 'SYNCING DRAFTS'),
      error: (e, s) => GlassErrorPlaceholder(message: 'DRAFTS UNAVAILABLE', error: e),
      data: (appState) {
        final office = appState.offices.firstWhere((o) => o.id == widget.branchId);
        
        final branchLoanIds = appState.customers
            .where((c) => c.officeId == widget.branchId)
            .expand((c) => appState.loans.where((l) => l.customerId == c.id).map((l) => l.id))
            .toSet();

        // Ensure we only show drafts for this branch and current period
        final drafts = appState.monthlyRecoveries.where((d) {
          final isSamePeriod = d.month == _currentMonth && d.year == _currentYear;
          final belongsToBranch = branchLoanIds.contains(d.loanId);
          return isSamePeriod && belongsToBranch;
        }).toList();

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
                      onTap: () => context.push('/branch/${widget.branchId}/preview/$_currentMonth/$_currentYear'),
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
                      SizedBox(
                        height: 48,
                        child: GestureDetector(
                          onTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final msg = await ref.read(appStateProvider.notifier).generateDrafts(_currentMonth, _currentYear, branchId: widget.branchId);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: AppTheme.accent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: GlassPill(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              drafts.isEmpty ? 'GENERATE DRAFTS' : 'REFRESH DRAFTS', 
                              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)
                            ),
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
                                  'Master Collection: $_currentMonth/$_currentYear', 
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
                                          DataColumn(label: Text('PRINCIPAL (₹)')),
                                          DataColumn(label: Text('INTEREST (₹)')),
                                          DataColumn(label: Text('PENAL (₹)')),
                                          DataColumn(label: Text('OTHERS (₹)')),
                                          DataColumn(label: Text('TOTAL (₹)')),
                                          DataColumn(label: Text('ADJUST')),
                                        ],
                                        rows: drafts.map((d) {
                                          final loan = appState.loans.firstWhere((l) => l.id == d.loanId);
                                          final customer = appState.customers.firstWhere((c) => c.id == loan.customerId);
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(customer.name.toUpperCase())),
                                              DataCell(Text(loan.accountNo)),
                                              DataCell(Text('₹${d.principalDue.toStringAsFixed(0)}')),
                                              DataCell(Text('₹${d.interest.toStringAsFixed(0)}')),
                                              DataCell(Text('₹${d.penalInterest.toStringAsFixed(0)}')),
                                              DataCell(Text('₹${d.otherCharges.toStringAsFixed(0)}')),
                                              DataCell(Text('₹${d.totalRecovered.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent))),
                                              DataCell(
                                                SizedBox(
                                                  height: 36,
                                                  width: 85,
                                                  child: GestureDetector(
                                                    onTap: () => _showEditEmiDialog(context, ref, d),
                                                    child: const GlassPill(
                                                      padding: EdgeInsets.zero,
                                                      child: Text('EDIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
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
      },
    );
  }

  void _showEditEmiDialog(BuildContext context, WidgetRef ref, MonthlyRecovery draft) {
    final principalCtrl = TextEditingController(text: draft.principalDue.toStringAsFixed(0));
    final interestCtrl = TextEditingController(text: draft.interest.toStringAsFixed(0));
    final penalCtrl = TextEditingController(text: draft.penalInterest.toStringAsFixed(0));
    final othersCtrl = TextEditingController(text: draft.otherCharges.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => _GlassInputDialog(
        title: 'Adjust Collection',
        subtitle: 'Update recovery fields for this draft.',
        controllers: {
          'Principal': principalCtrl,
          'Interest': interestCtrl,
          'Penal': penalCtrl,
          'Others': othersCtrl,
        },
        onConfirm: () {
          ref.read(appStateProvider.notifier).updateDraft(
            draft.id, 
            principalDue: double.tryParse(principalCtrl.text),
            interest: double.tryParse(interestCtrl.text),
            penalInt: double.tryParse(penalCtrl.text),
            others: double.tryParse(othersCtrl.text),
          );
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _GlassInputDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onConfirm;
  const _GlassInputDialog({required this.title, required this.subtitle, required this.controllers, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: IntrinsicHeight(
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 24),
                ...controllers.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: entry.key,
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.accent)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                )),
                const SizedBox(height: 12),
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
