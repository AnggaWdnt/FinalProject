import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:resepin/models/kategori_models.dart';
import 'dart:convert';

import 'food_list_screen.dart';
class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<KategoriModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/categories'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // ✅ Pastikan data adalah List
      if (jsonResponse['data'] is List) {
        final List rawData = jsonResponse['data'];
        setState(() {
          categories = rawData
              .map((json) => KategoriModel.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception(
            'Data kategori bukan List: ${jsonResponse['data']}');
      }
    } else {
      throw Exception(
          'Gagal memuat kategori: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetchCategories: $e');
    if (mounted) {
      setState(() {
        isLoading = false;
        categories = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Makanan')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text('Tidak ada kategori ditemukan'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final kategori = categories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(kategori.name),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodListScreen(
                                categoryId: kategori.id,
                                categoryName: kategori.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
