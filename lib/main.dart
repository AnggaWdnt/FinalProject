import 'package:flutter/material.dart';
import 'package:resepin/screens/category_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';

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
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // 🟡 Inisialisasi halaman pertama saat app dibuka
      home: const LoginScreen(),

      // ✅ Tambahkan semua route yang dibutuhkan
      routes: {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => RegisterScreen(),
  // jangan tambahkan dashboard di sini jika pakai push manual dengan userData
  '/categories': (context) => CategoryScreen(),
},

    );
  }
}
