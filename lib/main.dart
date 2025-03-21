import 'package:accento/frontend/UI/auth/splash_screen.dart';
import 'package:accento/utilities/constants.dart';
import 'package:accento/utilities/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp(); // Call the async initialization function
  runApp(const MyApp());
}

/// **Function to Initialize Firebase & SQLite**
Future<void> _initializeApp() async {
    await Firebase.initializeApp(); // Initialize Firebase
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI ACCENTO',
      theme: AppTheme.theme,
      // Initialize inside Builder for correct context
      home: Builder(
        builder: (context) {
          // This context now has proper MediaQuery access
          AppSizes.init(context);
          return SplashScreen();
        },
      ),
    );
  }
}
