import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    // ... (kode login Anda yang sudah benar)
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Terjadi kesalahan server');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw Exception('Server tidak merespons. Coba lagi nanti.');
    } catch (e) {
      rethrow;
    }
  }
  
  // FUNGSI REGISTER YANG DIPERBAIKI
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        // Ambil pesan error dari Laravel jika ada
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.values.first[0]);
        }
        throw Exception(data['message'] ?? 'Registrasi Gagal');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw Exception('Server tidak merespons.');
    } catch (e) {
      rethrow;
    }
  }

  // FUNGSI LOGOUT TUGASNYA JELAS: MEMBERSIHKAN SHARERED PREFERENCES
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    print("🚪 User logout & data SharedPreferences dihapus");
  }
}