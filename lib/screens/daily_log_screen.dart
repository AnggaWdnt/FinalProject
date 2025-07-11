import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_log_screen.dart';

class DailyLogScreen extends StatefulWidget {
  @override
  _DailyLogScreenState createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  List logs = [];
  bool isLoading = true;
  final String baseUrl = 'http://10.0.2.2:8000';
  final String token = '9|ZRtrqrFizh9jREeD6RVZXu0YFwXhNTLTuPJYG1kQ066e56ff'; // ✅ TOKEN

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse('$baseUrl/api/daily-logs'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        logs = json.decode(response.body);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat log harian')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteLog(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/daily-logs/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        '_method': 'DELETE',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Log berhasil dihapus')),
      );
      fetchLogs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus log')),
      );
    }
  }

  void showEditDialog(int id, String currentPortion) {
    final controller = TextEditingController(text: currentPortion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Log'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Porsi (gram/ml)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              editLog(id, controller.text);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> editLog(int id, String portion) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/daily-logs/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        '_method': 'PUT',
        'portion': portion,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Log berhasil diupdate')),
      );
      fetchLogs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate log')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Harian')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchLogs,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : logs.isEmpty
                  ? Center(child: Text('Belum ada log harian'))
                  : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('${log['food']['name']} (${log['portion']}g/ml)'),
                            subtitle: Text('Tanggal: ${log['date']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    showEditDialog(log['id'], log['portion'].toString());
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteLog(log['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddLogScreen(token: token)),
          );
          fetchLogs(); // ✅ Refresh list setelah tambah
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        tooltip: 'Tambah Log',
      ),
    );
  }
}
