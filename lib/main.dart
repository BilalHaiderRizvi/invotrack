import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invotrack/auth/email_verification.dart';
import 'package:invotrack/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';
import 'viewmodels/expense_view_model.dart';
import 'screens/expenses_screen.dart';

Future<void> _configureFirestore() async {
  if (kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint("⚠️ Firestore persistence error (web): $e");
    }
  } else {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _configureFirestore();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ExpenseService>(
          create: (_) => ExpenseService(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider<ExpenseViewModel>(
          create: (ctx) => ExpenseViewModel(
            auth: ctx.read<AuthService>(),
            expenseService: ctx.read<ExpenseService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'INVOTRACK',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final user = snapshot.data;
        
        // No user logged in
        if (user == null) {
          return const LoginScreen();
        }
        
        // User logged in but email not verified
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }
        
        // User logged in and email verified - initialize expense view model
        final expenseViewModel = context.read<ExpenseViewModel>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          expenseViewModel.init();
        });
        
        return const ExpensesScreen();
      },
    );
  }
}