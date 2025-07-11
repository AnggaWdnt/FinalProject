import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditLogScreen extends StatefulWidget {
  final Map log;
  final String token;
  final VoidCallback onLogUpdated;

  EditLogScreen({
    required this.log,
    required this.token,
    required this.onLogUpdated,
  });

  @override
  _EditLogScreenState createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  double? portion;
  String? date;

  @override
  void initState() {
    super.initState();
    portion = widget.log['portion'].toDouble();
    date = widget.log['date'];
  }

  Future<void> updateLog() async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/daily-logs/${widget.log['id']}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'portion': portion,
        'date': date,
        'food_id': widget.log['food']['id'],
      }),
    );

    if (response.statusCode == 200) {
      widget.onLogUpdated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal update log')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Log Harian')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: portion.toString(),
                decoration: InputDecoration(labelText: 'Porsi (gram/ml)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => portion = double.tryParse(value!),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan porsi' : null,
              ),
              TextFormField(
                initialValue: date,
                decoration: InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)'),
                onSaved: (value) => date = value,
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan tanggal' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    updateLog();
                  }
                },
                child: Text('Update'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
