import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. BU SATIRI EKLEYİN
import '../controllers/profile_controller.dart';
import '../model/user_model.dart';

class ProfilePage extends StatefulWidget {
  final Users user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfilePageController _controller;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = ProfilePageController(user: widget.user);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user.role ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil: ${widget.user.name ?? 'Kullanıcı'}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // 2. FLOATING ACTION BUTTON BURAYA EKLENDİ
      floatingActionButton: FloatingActionButton(
        onPressed: () => SystemNavigator.pop(),
        tooltip: 'Uygulamadan Çık',
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
        child: const Icon(Icons.exit_to_app, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                if (role == 'Veli' ||
                    role == 'Yönetici' ||
                    role == 'Öğretmen') ...[
                  TextField(
                    controller: _controller.schoolController,
                    decoration: const InputDecoration(
                      labelText: 'Okul',
                      prefixIcon: Icon(Icons.school),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (role == 'Veli' || role == 'Öğretmen') ...[
                  TextField(
                    controller: _controller.classController,
                    readOnly: role == 'Veli',
                    decoration: const InputDecoration(
                      labelText: 'Sınıf',
                      prefixIcon: Icon(Icons.class_),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],

                if (role == 'Veli') ...[
                  TextField(
                    controller: _controller.spouseController,
                    decoration: const InputDecoration(
                      labelText: 'Eş Bilgisi',
                      prefixIcon: Icon(Icons.group),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _controller.passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 22, 74),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bilgiler güncellendi! (Simülasyon)'),
                        ),
                      );
                    },
                    child: const Text(
                      'Bilgileri Güncelle',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}