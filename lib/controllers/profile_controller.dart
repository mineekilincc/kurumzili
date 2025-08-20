import 'package:flutter/material.dart';
import 'package:kurumzili/model/user_model.dart';
class ProfilePageController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = 'Veli'; // default rol, kullanıcıdan alınabilir
  final Users user;
  ProfilePageController({required this.user}) {
    loadUser(user);
  }

  void loadUser(Users user) {
    nameController.text = user.name ?? '';
    schoolNameController.text = user.schoolName ?? '';
    phoneController.text = user.phone?.toString() ?? '';
    usernameController.text = user.username ?? '';
    passwordController.text = user.password ?? '';
    selectedRole = user.role ?? 'Veli';
  }

  void dispose() {
    nameController.dispose();
    schoolNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  // BottomNavigationBar için örnek
  void onItemTapped(int index, BuildContext context) {
    // Navigation logic buraya
  }

  // Validator örnek
  String? validateTurkish(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName boş olamaz';
    return null;
  }
}
