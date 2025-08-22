import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPassword = false;

  void togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await _controller.login(context);

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.doorbell,
                    size: 80,
                    color: Color.fromARGB(255, 13, 22, 74),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "KURUM ZİLİ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 13, 22, 74),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hoş Geldiniz",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 13, 22, 74),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // TELEFON
                  TextFormField(
                    controller: _controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, color: Color.fromARGB(255, 13, 22, 74)),
                      labelText: "Telefon",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Telefon boş bırakılamaz";
                      if (value.length != 10) return "Telefon numarası geçersiz (10 haneli)";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ŞİFRE
                  TextFormField(
                    controller: _controller.passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 13, 22, 74)),
                      labelText: "Şifre",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color.fromARGB(255, 13, 22, 74),
                        ),
                        onPressed: togglePasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Şifre boş bırakılamaz";
                      if (value.length < 2) return "Şifre en az 2 karakter olmalı";
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // GİRİŞ BUTONU
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              "Giriş Yap",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
