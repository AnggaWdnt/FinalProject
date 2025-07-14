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
  File? imageFile;

  void _showAddLogDialog(BuildContext context) {
    final foodController = TextEditingController();
    final portionController = TextEditingController();
    final caloriesController = TextEditingController();
    String unit = 'gram';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Tambah Log Harian', style: TextStyle(fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setStateDialog(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(imageFile!, fit: BoxFit.cover),
                            )
                          : const Center(
                              child: Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: foodController,
                    decoration: InputDecoration(
                      labelText: 'Nama Makanan/Minuman',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.fastfood),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: portionController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Porsi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: unit,
                    decoration: InputDecoration(
                      labelText: 'Satuan',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.straighten),
                    ),
                    items: ['gram', 'ml', 'pcs']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase())))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setStateDialog(() => unit = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kalori (opsional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.local_fire_department),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  imageFile = null;
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
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
                    imageFile = null;
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Harian'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<DailyLogCubit, DailyLogState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '❌ Error: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (state.logs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data log',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                final imageUrl = log.photo != null
                    ? '${context.read<DailyLogCubit>().baseUrl}/storage/${log.photo}'
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.teal.withOpacity(0.3),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 60, color: Colors.grey);
                              },
                            ),
                          )
                        : const Icon(Icons.fastfood, color: Colors.orange, size: 60),
                    title: Text(
                      '${log.foodName} (${log.portion} ${log.unit})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🔥 Kalori: ${log.calories ?? 0} kcal',
                              style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          Text('📅 Tanggal: ${log.date ?? "-"}',
                              style: const TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddLogDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Tambah Log Harian',
      ),
    );
  }
}
