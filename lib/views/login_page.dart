import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../model/user_model.dart';
import 'velihome_page.dart';
import 'yoneticihome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _controller = LoginController();
  bool showPassword = false;
  bool isLoading = false;
  String usernameError = '';
  String passwordError = '';

  void validateUsername() {
    setState(() {
      if (_controller.usernameController.text.isEmpty) {
        usernameError = 'Kullanıcı adı boş bırakılamaz';
      } else if (_controller.usernameController.text.length < 1) {
        usernameError = 'Kullanıcı adı en az 1 karakter olmalı';
      } else {
        usernameError = '';
      }
    });
  }

  void validatePassword() {
    setState(() {
      if (_controller.passwordController.text.isEmpty ||
          _controller.passwordController.text.length < 1) {
        passwordError = 'Şifre en az 1 karakter olmalı';
      } else {
        passwordError = '';
      }
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> handleLogin() async {
    validateUsername();
    validatePassword();

    if (usernameError.isEmpty && passwordError.isEmpty) {
      setState(() => isLoading = true);
      await _controller.login(context);
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.doorbell, size: 80, color: Color.fromARGB(255, 13, 22, 74)),
                    const SizedBox(height: 2),
                    const Text("KURUM ZİLİ",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 13, 22, 74))),
                    const SizedBox(height: 2),
                    const Text("Hoş Geldiniz",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 13, 22, 74))),
                    const SizedBox(height: 32),

                    TextField(
                      controller: _controller.usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 13, 22, 74)),
                        labelText: "Kullanıcı Adı",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        errorText: usernameError.isEmpty ? null : usernameError,
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (_) => validateUsername(),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _controller.passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 13, 22, 74)),
                        labelText: "Şifre",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        errorText: passwordError.isEmpty ? null : passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off, color: const Color.fromARGB(255, 13, 22, 74)),
                          onPressed: togglePasswordVisibility,
                        ),
                      ),
                      onChanged: (_) => validatePassword(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                        ),
                        onPressed: isLoading ? null : handleLogin,
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text("Giriş Yap", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color.fromARGB(255, 13, 22, 74)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VelihomePage(user: Users(username: "Test Kullanıcısı")),
                            ),
                          );
                        },
                        child: const Text(
                          "Veli Ana Sayfa (Test)",
                          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 11, 16, 44)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color.fromARGB(255, 13, 22, 74)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YoneticihomePage(user: Users(username: "Test Kullanıcısı")),
                            ),
                          );
                        },
                        child: const Text(
                          "Yönetici Ana Sayfa (Test)",
                          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 11, 16, 44)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
