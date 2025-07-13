import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:resepin/models/kategori_models.dart';
import 'dart:convert';

import 'food_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
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

        if (jsonResponse['data'] is List) {
          final List rawData = jsonResponse['data'];
          if (mounted) {
            setState(() {
              categories =
                  rawData.map((json) => KategoriModel.fromJson(json)).toList();
              isLoading = false;
            });
          }
        } else {
          throw Exception('Data kategori bukan List: ${jsonResponse['data']}');
        }
      } else {
        throw Exception('Gagal memuat kategori: ${response.statusCode}');
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
      appBar: AppBar(
        title: const Text('Kategori Makanan'),
        backgroundColor: Colors.green.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text('Tidak ada kategori ditemukan'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final kategori = categories[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          kategori.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
