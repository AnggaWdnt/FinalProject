import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cubits/daily_log_cubit.dart';

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DailyLogCubit()..fetchDailyLogs(),
      child: const DailyLogView(),
    );
  }
}

class DailyLogView extends StatefulWidget {
  const DailyLogView({Key? key}) : super(key: key);

  @override
  State<DailyLogView> createState() => _DailyLogViewState();
}

class _DailyLogViewState extends State<DailyLogView> {
  String userRole = 'user';
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role') ?? 'user';
    });
  }

  void _showAddLogDialog(BuildContext context) {
    final foodController = TextEditingController();
    final portionController = TextEditingController();
    final caloriesController = TextEditingController();
    String unit = 'gram';

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Tambah Log Harian'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: imageFile != null
                        ? Image.file(imageFile!, fit: BoxFit.cover)
                        : const Center(child: Text('📸 Tambahkan Foto')),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: foodController,
                  decoration: const InputDecoration(labelText: 'Nama Makanan/Minuman'),
                ),
                TextField(
                  controller: portionController,
                  decoration: const InputDecoration(labelText: 'Porsi'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: unit,
                  items: ['gram', 'ml', 'pcs']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase())))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) unit = value;
                  },
                  decoration: const InputDecoration(labelText: 'Satuan'),
                ),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(labelText: 'Kalori (opsional)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final foodName = foodController.text.trim();
                final portion = int.tryParse(portionController.text.trim()) ?? 0;
                final calories = int.tryParse(caloriesController.text.trim()) ?? 0;

                if (foodName.isNotEmpty && portion > 0) {
                  context.read<DailyLogCubit>().addDailyLog(
                        foodName: foodName,
                        portion: portion,
                        unit: unit,
                        calories: calories,
                        photo: imageFile,
                      );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠ Nama & porsi wajib diisi')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Harian')),
      body: BlocBuilder<DailyLogCubit, DailyLogState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(child: Text('❌ Error: ${state.errorMessage}'));
          } else if (state.logs.isEmpty) {
            return const Center(child: Text('Belum ada data log'));
          } else {
            return ListView.builder(
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                final imageUrl = log.photo != null
                    ? '${context.read<DailyLogCubit>().baseUrl}/storage/${log.photo}'
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.fastfood, color: Colors.orange, size: 40),
                    title: Text('${log.foodName} (${log.portion} ${log.unit})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔥 Kalori: ${log.calories ?? 0} kcal'),
                        Text('📅 Tanggal: ${log.date ?? "-"}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: userRole == 'admin'
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddLogDialog(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}
