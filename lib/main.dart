import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'constants/app_themes.dart';
import 'services/firebase_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Attempt Firebase initialization
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization skipped/failed: $e");
  }

  // Initialize Hane database services (falls back to local database if Firebase is uninitialized)
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  // Try auto login
  final currentUser = await firebaseService.tryAutoLogin();

  runApp(MyApp(isLoggedIn: currentUser != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hane',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
