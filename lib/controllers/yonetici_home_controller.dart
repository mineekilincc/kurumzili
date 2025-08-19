import 'package:flutter/material.dart';
import 'package:kurumzili/views/adduser_page.dart';
import '../model/user_model.dart';
import '../views/profile_page.dart';


class YoneticiHomeController {
  final Users user; // Users nesnesi alınacak
  int selectedIndex = 0;
  final VoidCallback onStateChanged;

  YoneticiHomeController({required this.user, required this.onStateChanged}) {
    // TextField’ları kullanıcı bilgileriyle doldur
    nameController.text = user.name ?? '';
    usernameController.text = user.username ?? '';
    schoolNameController.text = user.schoolName ?? '';
    phoneController.text = user.phone?.toString() ?? '';
    emailController.text = user.email ?? '';
    passwordController.text = user.password ?? '';
  }

  // TextField kontrolleri
  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController usernameController = TextEditingController();
  late final TextEditingController schoolNameController = TextEditingController();
  late final TextEditingController phoneController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();

  void onItemTapped(BuildContext context, int index) {
  selectedIndex = index;
  onStateChanged();

  switch (index) {
    case 0:
      // Ana Sayfa (kendisi zaten home, gerekirse başka page açabilirsin)
      break;
    case 1:
      // Kullanıcı Ekle sayfasına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddUserPage(),
        ),
      );
      break;
    case 2:
      // Profil sayfasına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(user: user), // Users nesnesi gönder
        ),
      );
      break;
  }
}
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    schoolNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
