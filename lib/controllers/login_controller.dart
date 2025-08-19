import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../views/velihome_page.dart';
import '../views/yoneticihome_page.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError(context, "Kullanıcı adı ve şifre boş olamaz.");
      return;
    }

    isLoading = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showError(context, "Kullanıcı adı veya şifre hatalı.");
      } else {
        final userData = snapshot.docs.first.data();
        final user = Users.fromJson(userData);

        // Role ve username string olarak alınıyor
        user.role = userData['role']?.toString() ?? 'Veli';
        user.username = userData['username']?.toString() ?? 'Kullanıcı';

        debugPrint("Giriş yapan kullanıcı: ${user.username}, role: ${user.role}");

        Widget targetPage;
        if (user.role?.toLowerCase() == 'yönetici' ||
            user.role?.toLowerCase() == 'öğretmen') {
          targetPage = YoneticihomePage(user: user);
        } else {
          targetPage = VelihomePage(user: user);
        }

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetPage),
        );
      }
    } catch (e) {
      _showError(context, "Bir hata oluştu: $e");
    } finally {
      isLoading = false;
    }
  }
}
