import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../services/invoice_pdf_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _issuerName = TextEditingController(text: 'Your Company Name');
  final _issuerEmail = TextEditingController(text: 'youremail@company.com');
  final _issuerAddress = TextEditingController(text: '123 Business St, City, Country');
  final _clientName = TextEditingController(text: 'Client Name');
  final _clientEmail = TextEditingController(text: 'clientemail@gmail.com');
  final _clientAddress = TextEditingController(text: '456 Client Ave, City, Country');
  final _tax = TextEditingController(text: '5');
  final _discount = TextEditingController(text: '0');
  final List<InvoiceItem> _items = [];
  
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _issuerName.dispose();
    _issuerEmail.dispose();
    _issuerAddress.dispose();
    _clientName.dispose();
    _clientEmail.dispose();
    _clientAddress.dispose();
    _tax.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
          // If issue date is after due date, update due date too
          if (_issueDate.isAfter(_dueDate)) {
            _dueDate = _issueDate.add(const Duration(days: 7));
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) {
        final desc = TextEditingController();
        final qty = TextEditingController(text: '1');
        final rate = TextEditingController(text: '0');
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: qty,
                decoration: const InputDecoration(labelText: 'Qty'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: rate,
                decoration: const InputDecoration(labelText: 'Rate'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final q = int.tryParse(qty.text) ?? 1;
                final r = double.tryParse(rate.text) ?? 0;
                setState(
                  () => _items.add(
                    InvoiceItem(description: desc.text, quantity: q, rate: r),
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _generate() async {
    final invoice = Invoice(
      id: const Uuid().v4(),
      userId: 'local',
      number: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      issuerName: _issuerName.text,
      issuerEmail: _issuerEmail.text,
      issuerAddress: _issuerAddress.text,
      clientName: _clientName.text,
      clientEmail: _clientEmail.text,
      clientAddress: _clientAddress.text,
      issueDate: _issueDate,
      dueDate: _dueDate,
      items: _items,
      taxPercent: double.tryParse(_tax.text) ?? 0,
      discount: double.tryParse(_discount.text) ?? 0,
    );
    final file = await InvoicePdfService().generatePdf(invoice);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at: ${file.path}'))
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<double>(0, (s, i) => s + i.total);
    final taxAmount = total * (double.tryParse(_tax.text) ?? 0) / 100;
    final discountAmount = double.tryParse(_discount.text) ?? 0;
    final grandTotal = total + taxAmount - discountAmount;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Generator', style: TextStyle(fontSize: 20)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generate,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Issuer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _issuerName,
              decoration: const InputDecoration(labelText: 'Issuer Name'),
            ),
            TextField(
              controller: _issuerEmail,
              decoration: const InputDecoration(labelText: 'Issuer Email'),
            ),
            TextField(
              controller: _issuerAddress,
              decoration: const InputDecoration(labelText: 'Issuer Address'),
              maxLines: 2,
            ),
            
            const SizedBox(height: 20),
            const Text('Client Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _clientName,
              decoration: const InputDecoration(labelText: 'Client Name'),
            ),
            TextField(
              controller: _clientEmail,
              decoration: const InputDecoration(labelText: 'Client Email'),
            ),
            TextField(
              controller: _clientAddress,
              decoration: const InputDecoration(labelText: 'Client Address'),
              maxLines: 2,
            ),
            
            const SizedBox(height: 20),
            const Text('Invoice Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Issue Date'),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_issueDate)),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Due Date'),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tax,
                    decoration: const InputDecoration(labelText: 'Tax %'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _discount,
                    decoration: const InputDecoration(labelText: 'Discount'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._items.asMap().entries.map(
              (entry) => ListTile(
                title: Text(entry.value.description),
                subtitle: Text(
                  'Qty: ${entry.value.quantity} • Rate: ${entry.value.rate.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.value.total.toStringAsFixed(2)),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _removeItem(entry.key),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: ${total.toStringAsFixed(2)}'),
                    Text('Tax: ${taxAmount.toStringAsFixed(2)}'),
                    Text('Discount: ${discountAmount.toStringAsFixed(2)}'),
                    Text('Total: ${grandTotal.toStringAsFixed(2)}', 
                         style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

