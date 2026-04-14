import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';

class CustomerProfileScreen extends ConsumerWidget {
  final String customerId;

  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateAsync = ref.watch(appStateProvider);

    return appStateAsync.when(
      loading: () => const GlassLoadingPlaceholder(message: 'FETCHING PROFILE'),
      error: (e, s) => GlassErrorPlaceholder(message: 'PROFILE UNAVAILABLE', error: e),
      data: (appState) {
        final customer = appState.customers.firstWhere((c) => c.id == customerId);
        final office = appState.offices.firstWhere((o) => o.id == customer.officeId);
        final loans = appState.loans.where((l) => l.customerId == customerId).toList();

        return BackgroundScaffold(
          appBar: AppBar(
            title: const Text('Member Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
          floatingActionButton: SizedBox(
            height: 54,
            width: 150,
            child: GestureDetector(
              onTap: () => _showAddLoanModal(context, ref),
              child: const GlassPill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_add, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text('NEW LOAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.5, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 110,
                    child: GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('${office.name} Unit · Member #${customer.memberNo}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Financial Exposure',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: loans.isEmpty
                        ? const Center(child: Text('No active loan accounts found.', style: TextStyle(color: Colors.white24)))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: loans.length,
                            itemBuilder: (context, index) {
                              final loan = loans[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: SizedBox(
                                  height: 150,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(24),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('A/C ${loan.accountNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                              const SizedBox(height: 4),
                                              _StatusPill(status: loan.status),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  _LoanSmallStat(label: 'OUTSTANDING', value: '₹${loan.principalOutstanding.toStringAsFixed(0)}'),
                                                  const SizedBox(width: 24),
                                                  _LoanSmallStat(label: 'BASE EMI', value: '₹${loan.baseEmiAmount.toStringAsFixed(0)}', highlight: true),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                              onPressed: () => _showDeleteLoanDialog(context, ref, loan.id),
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              height: 40,
                                              width: 90,
                                              child: const GlassPill(
                                                child: Text('HISTORY', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
        );
      },
    );
  }

  void _showDeleteLoanDialog(BuildContext context, WidgetRef ref, String loanId) {
    showDialog(
      context: context,
      builder: (ctx) => _GlassDialog(
        title: 'Purge Loan Record?',
        content: 'This will permanently delete this loan account from the system.',
        onConfirm: () {
          ref.read(appStateProvider.notifier).deleteLoan(loanId);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showAddLoanModal(BuildContext context, WidgetRef ref) {
    final acCtrl = TextEditingController();
    final osCtrl = TextEditingController();
    final emiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _GlassInputDialog(
        title: 'Initialize New Loan',
        inputs: [
          _InputDef(controller: acCtrl, label: 'Account Number (XX/YY-ZZ)'),
          _InputDef(controller: osCtrl, label: 'Principal Outstanding Amount (₹)', keyboardType: TextInputType.number),
          _InputDef(controller: emiCtrl, label: 'Agreed Base EMI (₹)', keyboardType: TextInputType.number),
        ],
        onConfirm: () {
          ref.read(appStateProvider.notifier).addLoan(
                customerId,
                acCtrl.text,
                double.tryParse(osCtrl.text) ?? 0,
                double.tryParse(emiCtrl.text) ?? 0,
              );
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1),
        ),
      ),
    );
  }
}

class _LoanSmallStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _LoanSmallStat({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: highlight ? AppTheme.accent : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }
}

class _GlassDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  const _GlassDialog({required this.title, required this.content, required this.onConfirm});

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
                const SizedBox(height: 16),
                Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontSize: 12))),
                    const SizedBox(width: 16),
                    SizedBox(height: 42, width: 100, child: GestureDetector(onTap: onConfirm, child: const GlassPill(child: Text('WIPE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11))))),
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

class _InputDef {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  _InputDef({required this.controller, required this.label, this.keyboardType = TextInputType.text});
}

class _GlassInputDialog extends StatelessWidget {
  final String title;
  final List<_InputDef> inputs;
  final VoidCallback onConfirm;
  const _GlassInputDialog({required this.title, required this.inputs, required this.onConfirm});

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
                const SizedBox(height: 24),
                ...inputs.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: i.controller,
                    keyboardType: i.keyboardType,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: i.label,
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                )).toList(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontSize: 12))),
                    const SizedBox(width: 16),
                    SizedBox(height: 45, width: 130, child: GestureDetector(onTap: onConfirm, child: const GlassPill(child: Text('INITIALIZE', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11))))),
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
