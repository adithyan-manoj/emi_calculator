import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';

class BranchDetailsScreen extends ConsumerWidget {
  final String branchId;
  const BranchDetailsScreen({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider).requireValue;
    final office = appState.offices.firstWhere((o) => o.id == branchId);
    final customers =
        appState.customers.where((c) => c.officeId == branchId).toList();

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(office.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              height: 38,
              child: GestureDetector(
                onTap: () => context.push('/branch/$branchId/drafts'),
                child: const GlassPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.description_outlined, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Drafts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unit Members',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 30),
                  ),
                  SizedBox(
                    height: 48,
                    child: GestureDetector(
                      onTap: () => _showAddEmployeeModal(context, ref),
                      child: const GlassPill(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1_outlined, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text('ADD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: customers.isEmpty
                    ? const Center(
                        child: Text('No registered members in this unit.', style: TextStyle(color: Colors.white38)),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          final customerLoans = appState.loans
                              .where((l) => l.customerId == customer.id)
                              .toList();
                          final totalOs = customerLoans.fold(
                              0.0, (sum, l) => sum + l.principalOutstanding);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: SizedBox(
                              height: 140,
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.person_outline_rounded, color: Colors.white),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                              Text('ID: ${customer.memberNo}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                          onPressed: () => _showDeleteDialog(context, ref, customer.id, customer.name),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: 38,
                                          child: GestureDetector(
                                            onTap: () => context.push('/customer/${customer.id}'),
                                            child: const GlassPill(
                                              padding: EdgeInsets.symmetric(horizontal: 14),
                                              child: Text('MANAGE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    const Divider(color: Colors.white12, height: 1),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _StatItem(label: 'LOANS', value: '${customerLoans.length}'),
                                        _StatItem(label: 'OUTSTANDING', value: '₹${totalOs.toStringAsFixed(0)}', highlight: true),
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
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String customerId,
      String customerName) {
    showDialog(
      context: context,
      builder: (ctx) => _GlassDialog(
        title: 'Remove Member?',
        content: 'This will purge all active loan records for $customerName. This action cannot be undone.',
        onConfirm: () {
          ref.read(appStateProvider.notifier).deleteEmployee(customerId);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showAddEmployeeModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final memberCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _GlassInputDialog(
        title: 'New Member Registration',
        inputs: [
          _InputDef(controller: nameCtrl, label: 'Full Official Name'),
          _InputDef(controller: memberCtrl, label: 'Society Membership No.'),
        ],
        onConfirm: () {
          ref.read(appStateProvider.notifier).addEmployee(
              branchId, nameCtrl.text, memberCtrl.text);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _StatItem({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: highlight ? AppTheme.accent : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white54, fontSize: 12))),
                    const SizedBox(width: 16),
                    SizedBox(height: 40, width: 100, child: GestureDetector(onTap: onConfirm, child: const GlassPill(child: Text('PURGE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12))))),
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
  _InputDef({required this.controller, required this.label});
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
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: i.label,
                      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                )).toList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white54, fontSize: 12))),
                    const SizedBox(width: 16),
                    SizedBox(height: 40, width: 120, child: GestureDetector(onTap: onConfirm, child: const GlassPill(child: Text('CONFIRM', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12))))),
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
