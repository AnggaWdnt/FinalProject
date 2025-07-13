import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('user_name') ?? '';
    emailController.text = prefs.getString('user_email') ?? '';
  }

  Future<void> saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', nameController.text.trim());
    await prefs.setString('user_email', emailController.text.trim());

    setState(() => isLoading = false);
    Navigator.pop(context, true); // Kembali ke layar sebelumnya dengan tanda sudah update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email wajib diisi';
                  final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailReg.hasMatch(value)) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : saveUserData,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
