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
          pw.Header(
            level: 0,
            child: pw.Text('Invoice ${invoice.number}',
                style: pw.TextStyle(fontSize: 22)),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Billed To:'),
                pw.Text(invoice.clientName),
                if (invoice.clientEmail != null) pw.Text(invoice.clientEmail!),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text('Issue: ${df.format(invoice.issueDate)}'),
                pw.Text('Due: ${df.format(invoice.dueDate)}'),
              ]),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const ['Description', 'Qty', 'Rate', 'Total'],
            data: invoice.items
                .map((e) => [
                      e.description,
                      e.quantity,
                      e.rate.toStringAsFixed(2),
                      e.total.toStringAsFixed(2)
                    ])
                .toList(),
          ),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Subtotal: ${invoice.subTotal.toStringAsFixed(2)}'),
                pw.Text(
                    'Tax (${invoice.taxPercent.toStringAsFixed(0)}%): ${invoice.tax.toStringAsFixed(2)}'),
                pw.Text('Discount: ${invoice.discount.toStringAsFixed(2)}'),
                pw.SizedBox(height: 6),
                pw.Text('TOTAL: ${invoice.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Thank you!'),
        ],
      ),
    );

    // platform check
    if (Platform.isAndroid || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // ✅ Save to Downloads folder
      final downloads = Directory('/storage/emulated/0/Download'); // Android
      Directory saveDir = downloads;

      if (!(await downloads.exists())) {
        // Fallback for desktop
        final downloadsDir = await getDownloadsDirectory();
        saveDir = downloadsDir ?? await getApplicationDocumentsDirectory();
      }

      final file = File('${saveDir.path}/invoice_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } else if (Platform.isIOS) {
      // ✅ Save in app docs first
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open share dialog so user can export
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice');
      return file;
    } else {
      // fallback for unknown platforms
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    }
  }
}