import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resepin/cubits/daily_log_cubit.dart';
import 'package:geolocator/geolocator.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({Key? key}) : super(key: key);

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _portionController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedUnit = 'gram';
  File? _imageFile;
  bool _isSubmitting = false;

  double? _latitude;
  double? _longitude;

  final List<String> _unitOptions = ['gram', 'ml', 'pcs'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _portionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lokasi tidak aktif. Aktifkan GPS!')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Izin lokasi ditolak')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Izin lokasi permanen ditolak')),
      );
      return;
    }

    final position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📍 Lokasi belum tersedia, coba lagi')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final foodName = _foodNameController.text.trim();
    final portion = int.tryParse(_portionController.text.trim()) ?? 0;
    final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;

    await context.read<DailyLogCubit>().addDailyLog(
          foodName: foodName,
          portion: portion,
          unit: _selectedUnit,
          calories: calories,
          photo: _imageFile,
          latitude: _latitude,
          longitude: _longitude,
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Log berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = Colors.green.shade700;
    final borderRadius = BorderRadius.circular(12);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Log Harian'),
        backgroundColor: greenColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: borderRadius,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: borderRadius,
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Ketuk untuk pilih foto',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _foodNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Makanan / Minuman',
                  border: OutlineInputBorder(borderRadius: borderRadius),
                  prefixIcon: const Icon(Icons.fastfood),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? '⚠ Nama makanan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                items: _unitOptions
                    .map((unit) =>
                        DropdownMenuItem(value: unit, child: Text(unit.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUnit = val);
                },
                decoration: InputDecoration(
                  labelText: 'Satuan (gram/ml/pcs)',
                  border: OutlineInputBorder(borderRadius: borderRadius),
                  prefixIcon: const Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _portionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Porsi',
                  border: OutlineInputBorder(borderRadius: borderRadius),
                  prefixIcon: const Icon(Icons.format_list_numbered),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '⚠ Porsi wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kalori (kcal)',
                  hintText: 'Opsional jika ada di database',
                  border: OutlineInputBorder(borderRadius: borderRadius),
                  prefixIcon: const Icon(Icons.local_fire_department),
                ),
              ),
              const SizedBox(height: 20),
              if (_latitude != null && _longitude != null)
                Text(
                  '📍 Lokasi: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                  style: TextStyle(color: greenColor, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: borderRadius),
                        elevation: 3,
                      ),
                      onPressed: _submitLog,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
