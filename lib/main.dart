import 'package:flutter/material.dart';
import 'package:resepin/screens/login_screen.dart';
import 'package:resepin/screens/register_screen.dart';
import 'package:resepin/screens/dashboard_screen.dart';
import 'package:resepin/screens/category_screen.dart';
import 'package:resepin/screens/daily_log_screen.dart';
import 'package:resepin/screens/recipe_screen.dart';
import 'package:resepin/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resepin',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // PERBAIKAN UTAMA: Hapus parameter userData
        '/dashboard': (context) => const DashboardScreen(),
        '/categories': (context) =>  CategoryScreen(),
        '/daily-log': (context) => const DailyLogScreen(),
        '/recipes': (context) =>  RecipeScreen(),
        '/profile': (context) =>  ProfileScreen(),
      },
    );
  }
}