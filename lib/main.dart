import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      // ✅ Enable persistence with tab sync (web)
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        // Web automatically syncs tabs if persistenceEnabled = true
      );
    } catch (e) {
      debugPrint("⚠️ Firestore persistence error (web): $e");
    }
  } else {
    // ✅ On mobile, same settings API
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable offline cache for all platforms (v5+ way)
  await _configureFirestore();

  // Anonymous login for demo
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

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
          )..init(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'INVOTRACK',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        home: const ExpensesScreen(),
      ),
    );
  }
}