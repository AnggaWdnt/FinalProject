import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  FoodListScreen({required this.categoryId, required this.categoryName});

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  List foods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/foods?category_id=${widget.categoryId}'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        foods = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data makanan')),
      );
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : foods.isEmpty
              ? Center(child: Text('Tidak ada makanan di kategori ini'))
              : ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(food['name']),
                        subtitle: Text('${food['calories']} kcal'),
                      ),
                    );
                  },
                ),
    );
  }
}
