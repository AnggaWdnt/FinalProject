import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_log_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  // Gunakan Future untuk menampung token, ini kunci dari FutureBuilder
  late Future<String?> _tokenFuture;
  List _logs = [];
  String? _errorMessage;

  final String baseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    // Inisialisasi Future di initState
    _tokenFuture = _loadTokenAndFetchLogs();
  }

  // MENGGABUNGKAN LOGIKA: Ambil token, lalu langsung fetch data
  Future<String?> _loadTokenAndFetchLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("📦 Token diambil: $token");

    if (token == null || token.isEmpty) {
      if (mounted) _redirectToLogin();
      return null;
    }
    
    // Langsung fetch data setelah token valid
    await _fetchLogs(token);
    return token;
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  Future<void> _fetchLogs(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/daily-logs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _logs = json.decode(response.body);
          _errorMessage = null; // Hapus pesan error jika berhasil
        });
      } else if (response.statusCode == 401) {
        await AuthService().logout();
        _redirectToLogin();
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Harian')),
      body: FutureBuilder<String?>(
        future: _tokenFuture,
        builder: (context, snapshot) {
          // 1. Saat Future (memuat token & data awal) sedang berjalan
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Jika Future selesai tapi ada error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. Jika token null (sudah di-handle redirect)
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Token tidak ditemukan.'));
          }
          
          final token = snapshot.data!;

          // Tampilkan pesan error jika ada
          if (_errorMessage != null) {
            return Center(child: Text('Error: $_errorMessage'));
          }

          // Tampilkan daftar log atau pesan kosong
          return RefreshIndicator(
  onRefresh: () => _fetchLogs(token),
  child: _logs.isEmpty
      ? const Center(child: Text('Belum ada log harian.'))
      : ListView.builder(
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            final foodName = log['food_name'] ?? 'Tanpa Nama';
            final portion = log['portion']?.toString() ?? '0';
            final date = log['date'] ?? 'Tanpa Tanggal';
            // PERBAIKAN: Ambil data 'unit' dari API
            final unit = log['unit'] ?? 'gram'; 

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                // PERBAIKAN: Gabungkan porsi dengan satuannya
                title: Text('$foodName ($portion $unit)'),
                subtitle: Text('Tanggal: $date'),
              ),
            );
          },
        ),
);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final token = await _tokenFuture;
          if (token != null && mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddLogScreen(token: token)),
            );
            if (result == true) {
              // Refresh data setelah berhasil menambah log baru
              setState(() {
                // Reset future agar FutureBuilder rebuild dan fetch data baru
                _tokenFuture = _loadTokenAndFetchLogs();
              });
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}