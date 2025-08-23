import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../services/invoice_pdf_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _client = TextEditingController(text: 'Acme Corp');
  final _email = TextEditingController(text: 'billing@acme.com');
  final _tax = TextEditingController(text: '5');
  final _discount = TextEditingController(text: '0');
  final List<InvoiceItem> _items = [
    const InvoiceItem(description: 'Service A', quantity: 2, rate: 1500),
  ];

  @override
  void dispose() {
    _client.dispose();
    _email.dispose();
    _tax.dispose();
    _discount.dispose();
    super.dispose();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) {
        final desc = TextEditingController();
        final qty = TextEditingController();
        final rate = TextEditingController();
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: qty, decoration: const InputDecoration(labelText: 'Qty'), keyboardType: TextInputType.number),
            TextField(controller: rate, decoration: const InputDecoration(labelText: 'Rate'), keyboardType: TextInputType.number),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final q = int.tryParse(qty.text) ?? 1;
                final r = double.tryParse(rate.text) ?? 0;
                setState(() => _items.add(InvoiceItem(description: desc.text, quantity: q, rate: r)));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generate() async {
    final invoice = Invoice(
      id: const Uuid().v4(),
      userId: 'local',
      number: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      clientName: _client.text,
      clientEmail: _email.text,
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      items: _items,
      taxPercent: double.tryParse(_tax.text) ?? 0,
      discount: double.tryParse(_discount.text) ?? 0,
    );
    final file = await InvoicePdfService().generatePdf(invoice);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF saved at: ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<double>(0, (s, i) => s + i.total);
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Generator')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generate,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          TextField(controller: _client, decoration: const InputDecoration(labelText: 'Client Name')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Client Email')),
          Row(children: [
            Expanded(child: TextField(controller: _tax, decoration: const InputDecoration(labelText: 'Tax %'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _discount, decoration: const InputDecoration(labelText: 'Discount'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._items.map((e) => ListTile(
                title: Text(e.description),
                subtitle: Text('Qty: ${e.quantity} • Rate: ${e.rate.toStringAsFixed(2)}'),
                trailing: Text(e.total.toStringAsFixed(2)),
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
              const Spacer(),
              Text('Subtotal: ${total.toStringAsFixed(2)}'),
            ],
          )
        ]),
      ),
    );
  }
}
