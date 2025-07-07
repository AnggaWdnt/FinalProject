import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    final message = await AuthService().register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (message != null && message.toLowerCase().contains("berhasil")) {
      setState(() {
        successMessage = message;
        errorMessage = null;
      });
      nameController.clear();
      emailController.clear();
      passwordController.clear();
    } else {
      setState(() {
        errorMessage = message ?? "Terjadi kesalahan";
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
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(
                controller: nameController,
                hint: 'Nama Lengkap',
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              CustomInput(
                controller: emailController,
                hint: 'Email',
                validator: (value) {
                  if (value!.isEmpty) return 'Email tidak boleh kosong';
                  final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailReg.hasMatch(value)) return 'Format email salah';
                  return null;
                },
              ),
              CustomInput(
                controller: passwordController,
                hint: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Password tidak boleh kosong';
                  if (value.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (errorMessage != null)
                Text(errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14)),
              if (successMessage != null)
                Text(successMessage!,
                    style: TextStyle(color: Colors.green, fontSize: 14)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
