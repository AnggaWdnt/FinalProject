import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailRecipeScreen extends StatefulWidget {
  final int recipeId;

  DetailRecipeScreen({required this.recipeId});

  @override
  _DetailRecipeScreenState createState() => _DetailRecipeScreenState();
}

class _DetailRecipeScreenState extends State<DetailRecipeScreen> {
  final String baseUrl = 'http://10.0.2.2:8000';
  Map<String, dynamic>? recipe;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetail();
  }

  Future<void> fetchRecipeDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          recipe = json.decode(response.body);
          isLoading = false;
        });
      } else {
        showError('Gagal memuat detail resep');
      }
    } catch (e) {
      showError('Error: ${e.toString()}');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Resep')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recipe == null
              ? Center(child: Text('Resep tidak ditemukan'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe!['judul'] ?? 'Tanpa Judul',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        recipe!['deskripsi'] ?? 'Tidak ada deskripsi',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Bahan-bahan:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...List<Widget>.from((recipe!['bahan'] ?? []).map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('- $item'),
                        ),
                      )),
                      SizedBox(height: 20),
                      Text(
                        'Langkah-langkah:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...List<Widget>.from((recipe!['langkah_langkah'] ?? []).asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        ),
                      )),
                    ],
                  ),
                ),
    );
  }
}
