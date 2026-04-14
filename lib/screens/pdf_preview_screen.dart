import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../data/data_providers.dart';
import '../services/pdf_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_scaffold.dart';

class PdfPreviewScreen extends ConsumerWidget {
  final String branchId;
  final int month;
  final int year;
  const PdfPreviewScreen({super.key, required this.branchId, required this.month, required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateAsync = ref.watch(appStateProvider);

    return appStateAsync.when(
      loading: () => const GlassLoadingPlaceholder(message: 'PREPARING PDF'),
      error: (e, s) => GlassErrorPlaceholder(message: 'PDF GENERATION FAILED', error: e),
      data: (appState) {
        final office = appState.offices.firstWhere((o) => o.id == branchId);

        final branchLoanIds = appState.customers
            .where((c) => c.officeId == branchId)
            .expand((c) => appState.loans.where((l) => l.customerId == c.id).map((l) => l.id))
            .toSet();

        final branchDrafts = appState.monthlyRecoveries
            .where((d) => d.month == month && d.year == year && branchLoanIds.contains(d.loanId))
            .toList();

        if (branchDrafts.isEmpty) {
          return GlassErrorPlaceholder(
            message: 'NO DRAFTS FOUND',
            error: 'No recoveries generated for ${office.name} in $month/$year',
          );
        }

        return BackgroundScaffold(
          appBar: AppBar(
            title: const Text('Export Collection Draft'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: PdfPreview(
                        build: (format) => PdfService.generateRecoveryPdf(
                          office: office,
                          month: month,
                          year: year,
                          drafts: branchDrafts,
                          customers: appState.customers,
                          loans: appState.loans,
                        ),
                        allowPrinting: true,
                        allowSharing: true,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        previewPageMargin: const EdgeInsets.all(0),
                        pdfPreviewPageDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
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
}
