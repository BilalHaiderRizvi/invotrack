import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get uid => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password, {String? displayName}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      
      // Send verification email automatically
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Re-send verification email
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print('Verification email error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Reload user data (useful after email verification)
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      print('Update display name error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      print('Update email error: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}