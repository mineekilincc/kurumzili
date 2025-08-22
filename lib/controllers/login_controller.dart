import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/school_model.dart';
import '../views/mmhome_page.dart';
import '../views/velihome_page.dart';
import '../views/yoneticihome_page.dart';

class LoginController {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> login(BuildContext context) async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showError(context, "Telefon ve şifre boş olamaz.");
      return;
    }

    try {
      // Kullanıcıyı getir
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (!context.mounted) return;

      if (snapshot.docs.isEmpty) {
        _showError(context, "Telefon veya şifre hatalı.");
        return;
      }

      final userData = snapshot.docs.first.data();
      final user = Users.fromJson(userData);
      user.role = userData['role']?.toString() ?? 'Veli';

      // Okulu getir
      final snapSchool = await FirebaseFirestore.instance
          .collection('schools')
          .where('schoolId', isEqualTo: user.schoolId)
          .limit(1)
          .get();

      if (snapSchool.docs.isEmpty) {
        _showError(context, "Kullanıcıya ait okul bulunamadı.");
        return;
      }

      final schoolData = snapSchool.docs.first.data();
      final school = Schools.fromJson(schoolData);

      // ✅ Okulun aktiflik durumunu kontrol et
      // Bu kısım, veri tipi uyuşmazlığına karşı daha güvenli hale getirildi.
      bool isSchoolActive = schoolData['status'] == true;
      if (!isSchoolActive) {
        _showError(context, "Bu okul şu anda aktif değil. Lütfen yöneticiyle iletişime geçin.");
        return;
      }

      // Role bazlı yönlendirme
      Widget targetPage;
      final roleLower = user.role!.toLowerCase();
      if (roleLower == 'yönetici' || roleLower == 'öğretmen') {
        targetPage = YoneticihomePage(user: user);
      } else if (roleLower == 'uygulama yöneticisi') {
        targetPage = MainManagerHomePage(user: user);
      } else {
        targetPage = VelihomePage(user: user);
      }

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetPage),
      );
    } catch (e) {
      if (context.mounted) {
        _showError(context, "Bir hata oluştu: $e");
      }
    }
  }
}