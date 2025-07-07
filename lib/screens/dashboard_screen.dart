import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat datang, ${userData['name'] ?? 'User'}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Mau Tau Apa Hari Ini"),
            SizedBox(height: 32),

            // 🔽 Card: Navigasi ke Kategori
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/categories');
              },
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt),
                      SizedBox(width: 12),
                      Text("Lihat Kategori Resep", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // 🔽 Card: Navigasi ke Resep
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/recipes');
              },
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.food_bank),
                      SizedBox(width: 12),
                      Text("Lihat Semua Resep", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // ✅ Card Baru: Navigasi ke Favorit
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/favorites');
              },
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(width: 12),
                      Text("Resep Favorit", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // ✅ Card Baru: Navigasi ke Profil
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 12),
                      Text("Profil Saya", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
