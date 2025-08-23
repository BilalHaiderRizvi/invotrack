import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _db;
  ExpenseService(this._db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('expenses');

  Future<void> add(String uid, Expense expense) async {
    await _col(uid).doc(expense.id).set(expense.toJson(), SetOptions(merge: true));
  }

  Future<void> update(String uid, Expense expense) async {
    await _col(uid).doc(expense.id).update(expense.toJson());
  }

  Future<void> softDelete(String uid, String id) async {
    await _col(uid).doc(id).update({'isDeleted': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Stream<List<Expense>> streamByMonth(String uid, DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final q = _col(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .where('isDeleted', isEqualTo: false)
        .orderBy('date', descending: true);
    return q.snapshots().map((s) => s.docs.map((d) => Expense.fromJson(d.data())).toList());
  }
}
