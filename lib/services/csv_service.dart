import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class CsvService {
  Future<File> exportExpenses(List<Expense> expenses, {String fileName = 'expenses.csv'}) async {
    final rows = <List<dynamic>>[
      ['Title', 'Amount', 'Category', 'Date', 'Notes'],
      ...expenses.map((e) => [
            e.title,
            e.amount,
            e.category,
            e.date.toIso8601String(),
            e.notes ?? '',
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);
    return file;
  }
}
