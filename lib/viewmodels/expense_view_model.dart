import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../services/csv_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final AuthService auth;
  final ExpenseService expenseService;

  ExpenseViewModel({required this.auth, required this.expenseService});

  final _uuid = const Uuid();
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Expense> expenses = [];
  StreamSubscription? _sub;

  void init() {
    final uid = auth.uid;
    if (uid == null) {
      expenses = [];
      notifyListeners();
      return;
    }
    
    _sub?.cancel();
    _sub = expenseService.streamByMonth(uid, currentMonth).listen((data) {
      expenses = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
  }) async {
    final uid = auth.uid;
    if (uid == null) throw Exception('User not authenticated');
    
    final now = DateTime.now();
    final exp = Expense(
      id: _uuid.v4(),
      userId: uid,
      title: title,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await expenseService.add(uid, exp);
  }

  Future<void> deleteExpense(String id) async {
    final uid = auth.uid;
    if (uid == null) throw Exception('User not authenticated');
    
    await expenseService.softDelete(uid, id);
  }

  void goToPrevMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    init();
  }

  void goToNextMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    init();
  }

  double get total => expenses.fold(0, (s, e) => s + e.amount);

  Map<String, double> get byCategory {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<String> exportCsv() async {
    final file = await CsvService().exportExpenses(expenses);
    return file.path;
  }
}