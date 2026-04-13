import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/monthly_recovery.dart';
import '../models/customer.dart';
import '../models/loan.dart';
import '../models/office.dart';

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
    required List<Customer> customers,
    required List<Loan> loans,
  }) async {
    // Load exact custom Calibri fonts based on user specs
    final ByteData calibriData = await rootBundle.load('assets/fonts/calibri.ttf');
    final ByteData calibriBoldData = await rootBundle.load('assets/fonts/calibrib.ttf');

    final ttf = pw.Font.ttf(calibriData);
    final ttfBold = pw.Font.ttf(calibriBoldData);

    final pdf = pw.Document();

    final monthName = _months[month];

    // Replicate exactly the typos and spacing found in original pdf
    final headerText1 = 'Kollam District Postal Employees Welfare & Housing Co-';
    final headerText2 = 'operative Society Ltd.No.Q1446 , ';
    final headerText3 = 'Punalur.P.O, Kollam Dist ';
    final titleText = 'Recovery Schedule of HPO ${office.name} for the month of $monthName,$year ';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 14.16, vertical: 30.0), // approx margins from bbox
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10.6), // Top spacing matching y-axis offset
                pw.Text(headerText1, style: pw.TextStyle(font: ttfBold, fontSize: 20.04)),
                pw.SizedBox(height: 1.0),
                pw.Text(headerText2, style: pw.TextStyle(font: ttfBold, fontSize: 20.04)),
                pw.SizedBox(height: 10.0),
                pw.Text(headerText3, style: pw.TextStyle(font: ttfBold, fontSize: 20.04)),
                pw.SizedBox(height: 12.0),
                pw.Text(titleText, style: pw.TextStyle(font: ttfBold, fontSize: 15.96)),
                pw.SizedBox(height: 14.0),
                pw.Row(
                  children: [
                    pw.Text('No...........................', style: pw.TextStyle(font: ttf, fontSize: 15.96)),
                    pw.SizedBox(width: 80.0), // Mimicking 37 spaces
                    pw.Text('To', style: pw.TextStyle(font: ttf, fontSize: 15.96)),
                  ]
                ),
                pw.SizedBox(height: 11.0),
                pw.Row(
                  children: [
                     pw.SizedBox(width: 216.0),
                     pw.Text('The Post Master ${office.name} HPO ', style: pw.TextStyle(font: ttf, fontSize: 14.04)),
                  ]
                ),
                pw.SizedBox(height: 12.0),
                pw.Text('Dear sir, ', style: pw.TextStyle(font: ttf, fontSize: 14.04)),
                pw.SizedBox(height: 12.0),

                // Mimicking Exact paragraph spacing, typos and wrapping from baseline:
                pw.Text(
                  'As per Sub – Section (2) of section 37 , Rule 52 of the Kerala Co-Operative Societies Act ', 
                  style: pw.TextStyle(font: ttf, fontSize: 14.04)
                ),
                pw.SizedBox(height: 4.0),
                pw.Text(
                  '1969, We request you to be good enough to deduct from the salary of the following ', 
                  style: pw.TextStyle(font: ttf, fontSize: 14.04)
                ),
                pw.SizedBox(height: 4.0),
                pw.Text(
                  'employees of your Bank the amounts noted against each and remit to us towards their ', 
                  style: pw.TextStyle(font: ttf, fontSize: 14.04)
                ),
                pw.SizedBox(height: 4.0),
                pw.Text(
                  'loan accounts for the month and return the duplicate along with your D.D/pay order ', 
                  style: pw.TextStyle(font: ttf, fontSize: 14.04)
                ),
                pw.SizedBox(height: 13.0),
                pw.Text('Thanking you ', style: pw.TextStyle(font: ttf, fontSize: 14.04)),
                pw.SizedBox(height: 13.0),
                pw.Text("Your’s Faithfully ", style: pw.TextStyle(font: ttf, fontSize: 14.04)), // Note the specific quotation typo matching original
                pw.SizedBox(height: 13.0),
                pw.Text('Secretary', style: pw.TextStyle(font: ttf, fontSize: 14.04)),
                pw.SizedBox(height: 9.0),
              ],
            ),
            _buildDataTable(drafts, customers, loans, ttf, ttfBold),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDataTable(
    List<MonthlyRecovery> drafts, 
    List<Customer> customers, 
    List<Loan> loans, 
    pw.Font ttf, 
    pw.Font ttfBold
  ) {
    // 11 column definitions matching extraction exact sizes perfectly
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(35.0),
        1: const pw.FixedColumnWidth(78.0),
        2: const pw.FixedColumnWidth(56.0),
        3: const pw.FixedColumnWidth(63.0),
        4: const pw.FixedColumnWidth(49.0),
        5: const pw.FixedColumnWidth(35.0),
        6: const pw.FixedColumnWidth(42.0),
        7: const pw.FixedColumnWidth(35.0),
        8: const pw.FixedColumnWidth(36.0),
        9: const pw.FixedColumnWidth(34.0),
        10: const pw.FixedColumnWidth(55.0),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.white), // Mimics the clear background instead of grey200 
          children: [
            _buildHeaderCell('Memo\nNo.', ttf, 9.0),
            _buildHeaderCell('Name ', ttf, 9.96),
            _buildHeaderCell('Account\nNo. ', ttf, 9.96),
            _buildHeaderCell('Principal\nOutstanding', ttf, 9.96),
            _buildHeaderCell('Principal\nDue ', ttf, 9.0),
            _buildHeaderCell('EMI ', ttf, 9.96),
            _buildHeaderCell('Interest ', ttf, 9.0),
            _buildHeaderCell('Penal\nInt', ttf, 9.0),
            _buildHeaderCell('Notice ', ttf, 9.0),
            _buildHeaderCell('Others ', ttf, 8.04), // Specifically sized differently in reference!
            _buildHeaderCell('Total\namount to\nbe\nrecovered ', ttf, 9.96),
          ],
        ),
        // Table Rows
        ...drafts.map((draft) {
          final loan = loans.firstWhere((l) => l.id == draft.loanId);
          final customer = customers.firstWhere((c) => c.id == loan.customerId);
          
          final emi = draft.principalDue + draft.interest;
          final total = emi + draft.penalInterest + draft.otherCharges;

          return pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              _buildDataCell(customer.memberNo, ttf),
              _buildDataCell('${customer.name} ', ttf),
              _buildDataCell('${loan.accountNo} ', ttf),
              _buildDataCell('${loan.principalOutstanding.toStringAsFixed(0)} ', ttf),
              _buildDataCell('${draft.principalDue.toStringAsFixed(0)} ', ttf),
              _buildDataCell('${emi.toStringAsFixed(0)} ', ttf),
              _buildDataCell('${draft.interest.toStringAsFixed(0)} ', ttf),
              _buildDataCell(draft.penalInterest > 0 ? '${draft.penalInterest.toStringAsFixed(0)} ' : '- ', ttf),
              _buildDataCell('- ', ttf), 
              _buildDataCell(draft.otherCharges > 0 ? '${draft.otherCharges.toStringAsFixed(0)} ' : '- ', ttf),
              _buildDataCell('${total.toStringAsFixed(0)} ', ttf),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text, pw.Font font, double size) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 2, right: 2, top: 4, bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: size),
        textAlign: pw.TextAlign.left, // Original doesn't align center for headers horizontally mostly
      ),
    );
  }

  static pw.Widget _buildDataCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 4, right: 2, top: 4, bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 11.04),
        textAlign: pw.TextAlign.left, 
      ),
    );
  }
}
