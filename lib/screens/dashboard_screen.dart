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
            Text(
              "Selamat datang, ${userData['name'] ?? 'User'}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Hari ini Udah Hidup Sehat belum?"),
            SizedBox(height: 32),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/categories');
              },
              child: _buildCard(Icons.list, Colors.green, "Lihat Kategori Makanan"),
            ),
            SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/daily-log');
              },
              child: _buildCard(Icons.fastfood, Colors.orange, "Log Makanan & Minuman Harian"),
            ),
            SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/recipes');
              },
              child: _buildCard(Icons.menu_book, Colors.blue, "Resep"),
            ),
            SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: _buildCard(Icons.person, Colors.purple, "Profil Saya"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, Color color, String title) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
