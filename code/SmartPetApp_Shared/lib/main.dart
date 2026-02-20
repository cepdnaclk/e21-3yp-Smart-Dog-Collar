import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <- Make sure you generated this via flutterfire CLI
import 'core/theme/app_theme.dart';
import 'features/auth/screens/loading_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e, stack) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('$stack');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pet App',
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      // Start with LoadingScreen to handle async initialization or routing
      home: const LoadingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}