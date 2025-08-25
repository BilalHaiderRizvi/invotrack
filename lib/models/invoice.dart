class InvoiceItem {
  final String description;
  final int quantity;
  final double rate;
  const InvoiceItem({required this.description, required this.quantity, required this.rate});
  double get total => quantity * rate;

  Map<String, dynamic> toJson() => {'description': description, 'quantity': quantity, 'rate': rate};
  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'],
        quantity: json['quantity'],
        rate: (json['rate'] as num).toDouble(),
      );
}

class Invoice {
  final String id;
  final String userId;
  final String number;
  final String issuerName;
  final String? issuerEmail;
  final String issuerAddress;
  final String clientName;
  final String? clientEmail;
  final String clientAddress;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double taxPercent;
  final double discount; // flat
  final String status;

  Invoice({
    required this.id,
    required this.userId,
    required this.number,
    required this.issuerName,
    this.issuerEmail,
    required this.issuerAddress,
    required this.clientName,
    this.clientEmail,
    required this.clientAddress,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    this.taxPercent = 0,
    this.discount = 0,
    this.status = 'Draft',
  });

  double get subTotal => items.fold(0, (s, i) => s + i.total);
  double get tax => subTotal * (taxPercent / 100);
  double get total => subTotal + tax - discount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'number': number,
        'issuerName': issuerName,
        'issuerEmail': issuerEmail,
        'issuerAddress': issuerAddress,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientAddress': clientAddress,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'taxPercent': taxPercent,
        'discount': discount,
        'status': status,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        userId: json['userId'],
        number: json['number'],
        issuerName: json['issuerName'],
        issuerEmail: json['issuerEmail'],
        issuerAddress: json['issuerAddress'],
        clientName: json['clientName'],
        clientEmail: json['clientEmail'],
        clientAddress: json['clientAddress'],
        issueDate: DateTime.parse(json['issueDate']),
        dueDate: DateTime.parse(json['dueDate']),
        items: (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList(),
        taxPercent: (json['taxPercent'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        status: json['status'],
      );
}