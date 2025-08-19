// lib/views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:kurumzili/controllers/profile_controller.dart';
import '../model/user_model.dart';

class ProfilePage extends StatefulWidget {
  final Users user; // Kullanıcı bilgilerini alacak
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfilePageController _controller;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil: ${widget.user.username ?? 'Kullanıcı'}',style: TextStyle(color:Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 13, 22, 74),
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
                  controller: _controller.usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller.schoolNameController,
                  decoration: const InputDecoration(
                    labelText: 'Okul Adı',
                    prefixIcon: Icon(Icons.school),
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
                TextField(
                  controller: _controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller.passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),

                // Eğer kullanıcı Veli ise öğrenci bilgilerini göster
                if (widget.user.role == 'Veli') ...[
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Öğrenci Adı',
                      prefixIcon: Icon(Icons.child_care),
                    ),
                    controller: TextEditingController(
                      text: widget.user.name ?? '', // Öğrenci adı burada tutulabilir
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Sınıf',
                      prefixIcon: Icon(Icons.class_),
                    ),
                    controller: TextEditingController(
                      text: widget.user.schoolName ?? '', // Sınıf bilgisi burada tutulabilir
                    ),
                  ),
                ],

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
                      // Burada güncelleme işlemini ekleyebilirsin
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
