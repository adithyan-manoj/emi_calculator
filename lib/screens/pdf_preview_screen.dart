import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
import '../models/monthly_recovery.dart';
import '../models/office.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../theme/app_theme.dart';
import '../widgets/background_scaffold.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Office office;
  final int month;
  final int year;
  final List<MonthlyRecovery> drafts;
  final List<Customer> customers;
  final List<Loan> loans;

  const PdfPreviewScreen({
    super.key,
    required this.office,
    required this.month,
    required this.year,
    required this.drafts,
    required this.customers,
    required this.loans,
  });

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Recovery Schedule'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: PdfPreview(
            build: (format) => PdfService.generateRecoveryPdf(
              office: office,
              month: month,
              year: year,
              drafts: drafts,
              customers: customers,
              loans: loans,
            ),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName:
                'recovery_schedule_${office.name}_${month}_$year.pdf',
            previewPageMargin: const EdgeInsets.all(16),
            scrollViewDecoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.6),
            ),
            actions: const [],
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: Colors.transparent,
              iconColor: AppTheme.primary,
              textStyle: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
