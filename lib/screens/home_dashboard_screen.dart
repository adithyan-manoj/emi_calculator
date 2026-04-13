import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';
import 'splash_loading_screen.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateAsync = ref.watch(appStateProvider);

    return appStateAsync.when(
      loading: () => const SplashLoadingScreen(message: 'Connecting to Database...'),
      error: (error, stack) => BackgroundScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: GlassCard(
              child: Text(
                'Failed to load data: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      data: (appState) {
        final branches = appState.offices;

        return BackgroundScaffold(
          appBar: AppBar(
            title: const Text('Co-op Loan Recovery'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddBranchModal(context, ref),
            label: const Text(
              'Add Branch',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            backgroundColor: AppTheme.primary,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Header
                  Text(
                    'Select Branch',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 30,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage loan recoveries and draft reviews.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380,
                        childAspectRatio: 1.05,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: branches.length,
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        final employeeCount = appState.customers
                            .where((c) => c.officeId == branch.id)
                            .length;

                        return GestureDetector(
                          onTap: () => context.push('/branch/${branch.id}'),
                          child: GlassCard(
                            borderRadius: 22,
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.primary.withOpacity(0.14),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.business_outlined,
                                        size: 22,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red.shade400,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _showDeleteBranchDialog(
                                            context, ref, branch.id, branch.name);
                                      },
                                    ),
                                  ],
                                ),
                                // Name + count
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      branch.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(fontSize: 19, height: 1.2),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildPill('$employeeCount employees'),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ],
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
        );
      },
    );
  }

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  void _showDeleteBranchDialog(
      BuildContext context, WidgetRef ref, String branchId, String branchName) {
    showDialog(
      context: context,
      builder: (ctx) => _GlassAlertDialog(
        title: 'Delete Branch?',
        content:
            'Are you sure you want to delete $branchName? This will remove all employees and loans inside it.',
        confirmLabel: 'Delete',
        confirmColor: Colors.red,
        onConfirm: () {
          ref.read(appStateProvider.notifier).deleteBranch(branchId);
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showAddBranchModal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _GlassInputDialog(
        title: 'Add New Branch',
        fields: [
          _FieldDef(controller: controller, label: 'Branch Name'),
        ],
        confirmLabel: 'Add Branch',
        onConfirm: () {
          ref.read(appStateProvider.notifier).addBranch(controller.text);
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }
}

// ─── Reusable Glass Dialog Widgets ──────────────────────────────────────────

class _GlassAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _GlassAlertDialog({
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(content, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onConfirm,
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldDef {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _FieldDef({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
  });
}

class _GlassInputDialog extends StatelessWidget {
  final String title;
  final List<_FieldDef> fields;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _GlassInputDialog({
    required this.title,
    required this.fields,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...fields
                .map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextField(
                        controller: f.controller,
                        keyboardType: f.keyboardType,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: f.label,
                          labelStyle: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppTheme.divider,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppTheme.divider,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppTheme.accent,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: onConfirm,
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
