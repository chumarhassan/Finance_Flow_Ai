import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

// Web-specific imports - conditional
// ignore: avoid_web_libraries_in_flutter
import 'pdf_report_web.dart' if (dart.library.io) 'pdf_report_mobile.dart' as platform;

class PDFReportService {
  /// Generate PDF report and return bytes (works on all platforms)
  static Future<Uint8List> generateFinancialReportBytes({
    required List<TransactionModel> transactions,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final income = transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    final categoryData = <String, double>{};
    for (var transaction in transactions.where((t) => t.isExpense)) {
      categoryData[transaction.category] = (categoryData[transaction.category] ?? 0.0) + transaction.amount;
    }

    final sortedCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(userName, startDate, endDate),
          pw.SizedBox(height: 30),
          _buildSummarySection(income, expense, balance),
          pw.SizedBox(height: 30),
          _buildCategoryBreakdown(sortedCategories, expense),
          pw.SizedBox(height: 30),
          _buildTransactionsList(transactions),
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate and download report (main entry point)
  static Future<void> generateAndDownloadReport({
    required List<TransactionModel> transactions,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdfBytes = await generateFinancialReportBytes(
      transactions: transactions,
      userName: userName,
      startDate: startDate,
      endDate: endDate,
    );

    final fileName = 'FinanceFlow_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';

    await platform.downloadPDF(pdfBytes, fileName);
  }

  static pw.Widget _buildHeader(String userName, DateTime startDate, DateTime endDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Financial Report',
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated for: $userName',
          style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated on: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey500),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildSummarySection(double income, double expense, double balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Total Income', income, PdfColors.green700),
              _buildSummaryItem('Total Expense', expense, PdfColors.red700),
              _buildSummaryItem('Net Balance', balance, balance >= 0 ? PdfColors.green700 : PdfColors.red700),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: balance >= 0 ? PdfColors.green100 : PdfColors.red100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Savings Rate:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${income > 0 ? ((balance / income) * 100).toStringAsFixed(1) : '0.0'}%',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: balance >= 0 ? PdfColors.green900 : PdfColors.red900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, double amount, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          '\$${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }

  static pw.Widget _buildCategoryBreakdown(List<MapEntry<String, double>> categories, double totalExpense) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Spending by Category',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        if (categories.isEmpty)
          pw.Text('No expense data available', style: const pw.TextStyle(color: PdfColors.grey600))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Category', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                  _buildTableCell('Percentage', isHeader: true),
                ],
              ),
              ...categories.take(10).map((entry) {
                final percentage = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0.0;
                return pw.TableRow(
                  children: [
                    _buildTableCell(entry.key),
                    _buildTableCell('\$${entry.value.toStringAsFixed(2)}'),
                    _buildTableCell('${percentage.toStringAsFixed(1)}%'),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildTransactionsList(List<TransactionModel> transactions) {
    final recentTransactions = transactions.take(20).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recent Transactions (Last 20)',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          pw.Text('No transactions available', style: const pw.TextStyle(color: PdfColors.grey600))
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Date', isHeader: true),
                  _buildTableCell('Description', isHeader: true),
                  _buildTableCell('Category', isHeader: true),
                  _buildTableCell('Amount', isHeader: true),
                ],
              ),
              ...recentTransactions.map((transaction) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(DateFormat('MMM dd').format(transaction.date)),
                    _buildTableCell(transaction.description),
                    _buildTableCell(transaction.category),
                    _buildTableCell(
                      '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                      color: transaction.isExpense ? PdfColors.red700 : PdfColors.green700,
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.grey900 : PdfColors.grey800),
        ),
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Text(
          'Finance Flow AI - Smart Personal Finance & Expense Analyzer',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          'This report is automatically generated and for personal use only.',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }
}
