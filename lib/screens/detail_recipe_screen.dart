import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailRecipeScreen extends StatefulWidget {
  final int recipeId;

  DetailRecipeScreen({required this.recipeId});

  @override
  _DetailRecipeScreenState createState() => _DetailRecipeScreenState();
}

class _DetailRecipeScreenState extends State<DetailRecipeScreen> {
  final String baseUrl = 'http://10.0.2.2:8000';
  final String token = '9|ZRtrqrFizh9jREeD6RVZXu0YFwXhNTLTuPJYG1kQ066e56ff';
  Map<String, dynamic>? recipe;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetail();
  }

  Future<void> fetchRecipeDetail() async {
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
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe!['title'] ?? 'Tanpa Judul',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        recipe!['description'] ?? 'Tidak ada deskripsi',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Kategori: ${recipe!['category']?['name'] ?? 'Tidak ada'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Bahan-bahan:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...List<Widget>.from((recipe!['ingredients'] ?? []).map(
                        (item) => Text('- $item'),
                      )),
                      SizedBox(height: 20),
                      Text(
                        'Langkah-langkah:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...List<Widget>.from((recipe!['steps'] ?? []).map(
                        (item) => Text('${recipe!['steps'].indexOf(item) + 1}. $item'),
                      )),
                    ],
                  ),
                ),
    );
  }
}
