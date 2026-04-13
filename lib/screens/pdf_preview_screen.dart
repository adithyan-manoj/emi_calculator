import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
import '../data/data_providers.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_card.dart';

class PdfPreviewScreen extends ConsumerWidget {
  final String branchId;

  const PdfPreviewScreen({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider).requireValue;
    final office = appState.offices.firstWhere((o) => o.id == branchId);
    
    // Get loans for this branch
    final branchLoanIds = appState.customers
        .where((c) => c.officeId == branchId)
        .expand((c) => appState.loans.where((l) => l.customerId == c.id).map((l) => l.id))
        .toSet();

    final month = DateTime.now().month;
    final year = DateTime.now().year;

    // Get drafts for this month and branch
    final drafts = appState.monthlyRecoveries
        .where((d) => d.month == month && d.year == year && branchLoanIds.contains(d.loanId))
        .toList();

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Text(
                'Collection Report: ${office.name}'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PdfPreview(
                      build: (format) => PdfService.generateRecoveryPdf(
                        office: office,
                        month: month,
                        year: year,
                        drafts: drafts,
                        customers: appState.customers,
                        loans: appState.loans,
                      ),
                      allowPrinting: true,
                      allowSharing: true,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      maxPageWidth: 700,
                      loadingWidget: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      pdfPreviewPageDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
