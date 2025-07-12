import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddLogScreen extends StatefulWidget {
  final String token;
  const AddLogScreen({super.key, required this.token});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _portionController = TextEditingController();
  final _dateController = TextEditingController();

  String _selectedUnit = 'gram';
  bool _isSubmitting = false;
  final String baseUrl = 'http://10.0.2.2:8000/api';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T').first;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _portionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    // Jalankan validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/daily-logs'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'food_name': _foodNameController.text.trim(),
          'portion': _portionController.text.trim(),
          'unit': _selectedUnit,
          'date': _dateController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log berhasil ditambahkan!')),
        );
        Navigator.pop(context, true); // Kirim 'true' untuk menandakan sukses
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${error['message'] ?? 'Server error'}')),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Log Harian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Makanan/Minuman',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3, // Beri ruang lebih untuk angka
                    child: TextFormField(
                      controller: _portionController,
                      decoration: const InputDecoration(
                        labelText: 'Porsi',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Porsi tidak boleh kosong' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2, // Ruang lebih kecil untuk satuan
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['gram', 'ml'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedUnit = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    _dateController.text = picked.toIso8601String().split('T').first;
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                child: _isSubmitting 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}