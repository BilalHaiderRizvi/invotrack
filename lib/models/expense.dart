import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'amount': amount,
        'category': category,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'isDeleted': isDeleted,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: (json['date'] as Timestamp).toDate(),
      notes: json['notes'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}
