import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
  });

  final response = await AuthService().register(
    nameController.text.trim(),
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  if (response['success']) {
    setState(() {
      successMessage = response['message'];
      errorMessage = null;
    });

    nameController.clear();
    emailController.clear();
    passwordController.clear();
  } else {
    setState(() {
      errorMessage = response['message'];
      successMessage = null;
    });
  }
}


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(
                controller: nameController,
                hint: 'Nama Lengkap',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: emailController,
                hint: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                  final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailReg.hasMatch(value)) return 'Format email salah';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: passwordController,
                hint: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                  if (value.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (errorMessage != null)
                Text(errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
              if (successMessage != null)
                Text(successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Register"),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Sudah punya akun? Login",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
