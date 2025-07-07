import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List categories = [];
  final TextEditingController _controller = TextEditingController();

  final String baseUrl = "http://10.0.2.2/resepin_api";

  Future<void> fetchCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/get_categories.php'));
    final data = jsonDecode(res.body);

    if (data['status'] == 'success') {
      setState(() {
        categories = data['data'];
      });
    }
  }

  Future<void> addCategory() async {
    final res = await http.post(
      Uri.parse('$baseUrl/add_category.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": _controller.text}),
    );
    final data = jsonDecode(res.body);

    if (data['status'] == 'success') {
      _controller.clear();
      fetchCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kategori Resep")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Nama Kategori",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addCategory,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return ListTile(
                    title: Text(item['name']),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
