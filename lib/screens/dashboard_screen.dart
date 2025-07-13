import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart';
import '../services/auth_service.dart';
import 'cek_kalori_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = 'Tamu';
  Future<Map<String, dynamic>>? kaloriStatus;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshKaloriStatus();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Tamu';
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<Map<String, dynamic>> fetchKaloriStatus() async {
    const String apiUrl = 'http://10.0.2.2:8000/api/kalori/check';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat status kalori (${response.statusCode})');
    }
  }

  void _refreshKaloriStatus() {
    setState(() {
      kaloriStatus = fetchKaloriStatus();
    });
  }

  Widget _buildClickableCard(IconData icon, Color color, String title, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(fontSize: 18, color: Colors.grey[800], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50, // background hijau muda
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshKaloriStatus();
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat datang, $userName",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hari ini Udah ngapain aja?",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                FutureBuilder<Map<String, dynamic>>(
                  future: kaloriStatus,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCard();
                    } else if (snapshot.hasError) {
                      return _buildErrorCard(snapshot.error.toString());
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      final isHealthy = data['status'] == 'approve';
                      final totalKalori = data['total_kalori'];
                      final message = data['message'];

                      return _buildKaloriCard(isHealthy, totalKalori, message);
                    } else {
                      return const Text('Tidak ada data kalori');
                    }
                  },
                ),

                const SizedBox(height: 24),

                _buildClickableCard(
                  Icons.list,
                  Colors.green.shade700,
                  "Lihat Kategori Makanan",
                  () {
                    Navigator.pushNamed(context, '/categories');
                  },
                ),
                const SizedBox(height: 16),

                _buildClickableCard(
                  Icons.fastfood,
                  Colors.orange.shade700,
                  "Log Makanan & Minuman Harian",
                  () {
                    Navigator.pushNamed(context, '/daily-log');
                  },
                ),
                const SizedBox(height: 16),

                _buildClickableCard(
                  Icons.health_and_safety,
                  Colors.teal.shade700,
                  "Cek Status Kalori Harian",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CekKaloriScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildClickableCard(
                  Icons.menu_book,
                  Colors.blue.shade700,
                  "Resep",
                  () {
                    Navigator.pushNamed(context, '/recipes');
                  },
                ),
                const SizedBox(height: 16),

                _buildClickableCard(
                  Icons.person,
                  Colors.purple.shade700,
                  "Profil Saya",
                  () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.green),
          ),
          SizedBox(width: 16),
          Text(
            "Memuat status kalori...",
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade400, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Error: $error',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaloriCard(bool isHealthy, int totalKalori, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$message\nTotal: $totalKalori kcal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
