import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get uid => _auth.currentUser?.uid;
}
