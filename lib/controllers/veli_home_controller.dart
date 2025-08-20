import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../views/profile_page.dart'; // ProfilePage dosyasını import et

class VeliHomeController {
  final Users user; // Users nesnesini al
  int selectedIndex = 0;
  final VoidCallback onStateChanged;

  VeliHomeController({required this.user, required this.onStateChanged}) {
  nameController.text = user.name ?? '';
  phoneController.text = user.phone ?? '';
  // usernameController artık gerekli değilse kullanmayabilirsin
}


  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController schoolNameController = TextEditingController();
  late final TextEditingController phoneController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();

  void onItemTapped(BuildContext context, int index) {
    selectedIndex = index;
    onStateChanged();

    switch (index) {
      case 0:
        // Ana Sayfa (kendisi zaten home)
        break;
      case 1:
        // QR Kod Okut (kendin yönlendirebilirsin)
        break;
      case 2:
        // Profil sayfasına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(user: user), // Users nesnesi gönderiliyor
          ),
        );
        break;
    }
  }

  void dispose() {
    nameController.dispose();
    schoolNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
