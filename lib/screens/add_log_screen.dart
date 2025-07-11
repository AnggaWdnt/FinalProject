import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddLogScreen extends StatefulWidget {
  final String token;

  AddLogScreen({required this.token});

  @override
  _AddLogScreenState createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final String baseUrl = 'http://10.0.2.2:8000';

  String foodName = '';
  String portion = '';
  String date = '';

  bool isSubmitting = false;

  Future<void> addLog() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/daily-logs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'food_name': foodName.trim(), // 🆕 Trim input biar aman
          'portion': portion.trim(),
          'date': date.trim(),
        },
      ).timeout(const Duration(seconds: 10)); // 🆕 Timeout 10 detik

      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Log berhasil ditambahkan')),
        );
        Navigator.pop(context, true); // 🟢 Balik & refresh data
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal: ${error['message'] ?? 'Server error'}')),
        );
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Log Harian')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Nama Makanan/Minuman'),
              onChanged: (value) {
                foodName = value;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Porsi (gram/ml)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                portion = value;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
              keyboardType: TextInputType.datetime,
              onChanged: (value) {
                date = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (foodName.isNotEmpty && portion.isNotEmpty && date.isNotEmpty) {
                        addLog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('📋 Isi semua field')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
