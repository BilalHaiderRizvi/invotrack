import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/invoice.dart';

class InvoicePdfService {
  Future<File> generatePdf(Invoice invoice) async {
    final pdf = pw.Document();
    final df = DateFormat('yMMMd');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          // Header with invoice number and dates
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Invoice #: ${invoice.number}'),
                  pw.Text('Issue Date: ${df.format(invoice.issueDate)}'),
                  pw.Text('Due Date: ${df.format(invoice.dueDate)}'),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 20),
          
          // Issuer and client information in two columns
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Issuer information
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice.issuerName),
                  if (invoice.issuerEmail != null) pw.Text(invoice.issuerEmail!),
                  pw.Text(invoice.issuerAddress),
                ],
              ),
              
              // Client information
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice.clientName),
                  if (invoice.clientEmail != null) pw.Text(invoice.clientEmail!),
                  pw.Text(invoice.clientAddress),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 30),
          
          // Invoice items table
          pw.TableHelper.fromTextArray(
            headers: ['Description', 'Qty', 'Rate', 'Total'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            data: invoice.items
                .map((e) => [
                      e.description,
                      e.quantity.toString(),
                      e.rate.toStringAsFixed(2),
                      e.total.toStringAsFixed(2)
                    ])
                .toList(),
          ),
          
          pw.SizedBox(height: 20),
          
          // Summary section
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subtotal:'),
                      pw.Text(invoice.subTotal.toStringAsFixed(2)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tax (${invoice.taxPercent.toStringAsFixed(0)}%):'),
                      pw.Text(invoice.tax.toStringAsFixed(2)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount:'),
                      pw.Text(invoice.discount.toStringAsFixed(2)),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.total.toStringAsFixed(2), 
                             style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          pw.SizedBox(height: 30),
          
          // Footer with thank you message
          pw.Center(
            child: pw.Text('Thank you for your business!', 
                          style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    // Save file logic (unchanged)
    if (Platform.isAndroid || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final downloads = Directory('/storage/emulated/0/Download');
      Directory saveDir = downloads;

      if (!(await downloads.exists())) {
        final downloadsDir = await getDownloadsDirectory();
        saveDir = downloadsDir ?? await getApplicationDocumentsDirectory();
      }

      final file = File('${saveDir.path}/invoice_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice');
      return file;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    }
  }
}