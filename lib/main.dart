// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mastery/screen/cart_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/main_wrapper.dart';
import 'screen/login_screen.dart';
import 'screen/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment variables
  await dotenv.load(fileName: ".env");

  // Stripe Setup
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? "";

  // Firebase Initialize
  await Firebase.initializeApp();

  // Check Login Status
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isLoggedIn ? '/' : '/login',
      routes: {
        '/': (context) => const MainWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/cart': (context) => const CartScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Pet Food Store',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42),
          primary: const Color(0xFFFF8C42),
          secondary: const Color(0xFF2A52BE),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
