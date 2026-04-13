import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/monthly_recovery.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/office.dart';
import '../data/dummy_data.dart';

class PdfService {
  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static Future<Uint8List> generateRecoveryPdf({
    required Office office,
    required int month,
    required int year,
    required List<MonthlyRecovery> drafts,
  }) async {
    final pdf = pw.Document();

    final monthName = _months[month];
    final headerText1 = 'Kollam District Postal Employees Welfare & Housing Co-\noperative Society Ltd.No.Q1446 ,';
    final headerText2 = 'Punalur.P.O, Kollam Dist';
    final titleText = 'Recovery Schedule of HPO ${office.name} for the month of $monthName,$year';
    final legalText = 'As per Sub – Section (2) of section 37 , Rule 52 of the Kerala Co-Operative Societies Act 1969, We request you to be good enough to deduct from the salary of the following employees of your Bank the amounts noted against each and remit to us towards their loan accounts for the month and return the duplicate along with your D.D/pay order';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4, 
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(headerText1, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, lineSpacing: 2)),
                pw.SizedBox(height: 12),
                pw.Text(headerText2, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 24),
                pw.Text(titleText, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 24),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('No...........................', style: const pw.TextStyle(fontSize: 12)),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('To', style: const pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 12),
                        pw.Text('       The Post Master ${office.name} HPO', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text('Dear sir,', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 12),
                pw.Text(legalText, style: const pw.TextStyle(fontSize: 12, lineSpacing: 4), textAlign: pw.TextAlign.justify),
                pw.SizedBox(height: 32),
                pw.Text('Thanking you', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 16),
                pw.Text("Your's Faithfully", style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 16),
                pw.Text('Secretary', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 32),
              ],
            ),
            _buildDataTable(drafts),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDataTable(List<MonthlyRecovery> drafts) {
    final tableHeaders = [
      'Memo\nNo.', 'Name', 'Account\nNo.', 'Principal\nOutstanding', 
      'Principal\nDue', 'EMI', 'Interest', 'Penal\nInt', 'Notice',
      'Others', 'Total\namount to\nbe\nrecovered'
    ];

    final tableData = drafts.map((draft) {
      final loan = DummyData.loans.firstWhere((l) => l.id == draft.loanId);
      final customer = DummyData.customers.firstWhere((c) => c.id == loan.customerId);
      
      final emi = draft.principalDue + draft.interest;
      final total = emi + draft.penalInterest + draft.otherCharges;

      return [
        customer.memberNo,
        customer.name,
        loan.accountNo,
        loan.principalOutstanding.toStringAsFixed(0),
        draft.principalDue.toStringAsFixed(0),
        emi.toStringAsFixed(0),
        draft.interest.toStringAsFixed(0),
        draft.penalInterest > 0 ? draft.penalInterest.toStringAsFixed(0) : '-',
        '-', // Notice is not in data yet
        draft.otherCharges > 0 ? draft.otherCharges.toStringAsFixed(0) : '-',
        total.toStringAsFixed(0),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: tableHeaders,
      data: tableData,
      border: pw.TableBorder.all(width: 0.5),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.center, 
    );
  }
}
