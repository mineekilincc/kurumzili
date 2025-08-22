import 'package:flutter/material.dart';
import '../model/user_model.dart';

class ProfilePageController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController spouseController = TextEditingController();

  final Users user;

  ProfilePageController({required this.user}) {
    loadUser(user);
  }

  void loadUser(Users user) {
    nameController.text = user.name ?? '';
    phoneController.text = user.phone ?? '';
    schoolController.text = user.schoolName ?? '';
    
    // HATA BURADAYDI, DÜZELTİLDİ:
    // Liste elemanlarını virgül ve boşlukla birleştirerek tek bir String'e dönüştür.
    classController.text = user.studentclasses?.join(', ') ?? '';
    
    passwordController.text = user.password ?? '';
    spouseController.text = user.spouseName ?? '';
  }

  void dispose() {
    nameController.dispose();
    schoolController.dispose();
    classController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    spouseController.dispose();
  }
}