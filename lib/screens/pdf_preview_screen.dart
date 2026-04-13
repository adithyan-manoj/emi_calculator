import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
import '../models/monthly_recovery.dart';
import '../models/office.dart';
import '../theme/app_theme.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Office office;
  final int month;
  final int year;
  final List<MonthlyRecovery> drafts;

  const PdfPreviewScreen({
    super.key,
    required this.office,
    required this.month,
    required this.year,
    required this.drafts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recovery Schedule PDF Preview'),
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateRecoveryPdf(
          office: office,
          month: month,
          year: year,
          drafts: drafts,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'recovery_schedule_${office.name}_${month}_$year.pdf',
        previewPageMargin: const EdgeInsets.all(16),
        scrollViewDecoration: const BoxDecoration(
          color: AppTheme.background,
        ),
      ),
    );
  }
}
