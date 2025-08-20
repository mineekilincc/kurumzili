import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/school_model.dart';

class AddUserController {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final schoolNameController = TextEditingController();
  final schoolIdController = TextEditingController();
  final classController = TextEditingController();
  final studentNameController = TextEditingController();

  final List<String> roles = ['Veli', 'Öğretmen'];
  String? selectedRole;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SchoolModel> allowedSchools = []; // Müdürün görebileceği okullar
  SchoolModel? selectedSchool;
  String? selectedClass;
  String? selectedStudent;

  List<String> filteredClasses = [];
  List<String> filteredStudents = [];

  /// Müdür için izin verilen okulları ayarla
  void setAllowedSchools(List<SchoolModel> schools) {
    allowedSchools = schools;
    if (allowedSchools.isNotEmpty) {
      selectedSchool = allowedSchools.first;
      filteredClasses = selectedSchool!.classes;
    } else {
      selectedSchool = null;
      filteredClasses = [];
    }
  }

  void onSchoolSelected(SchoolModel? school) {
    selectedSchool = school;
    schoolNameController.text = school?.schoolName ?? '';
    filteredClasses = school?.classes ?? [];
    selectedClass = null;
    filteredStudents = [];
    selectedStudent = null;
    studentNameController.text = '';
  }

  void onClassSelected(String? className) {
    selectedClass = className;
    classController.text = className ?? '';
    filteredStudents = selectedSchool?.students[className] ?? [];
    selectedStudent = null;
    studentNameController.text = '';
  }

  void onStudentSelected(String? studentName) {
    selectedStudent = studentName;
    studentNameController.text = studentName ?? '';
  }

  Future<String?> addUser() async {
    try {
      final phone = phoneController.text.trim();
      if (phone.isEmpty) return 'Telefon boş olamaz';
      final phoneRegex = RegExp(r'^[0-9]{10}$');
      if (!phoneRegex.hasMatch(phone)) return 'Telefon 10 haneli olmalı';

      final query = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();
      if (query.docs.isNotEmpty) return 'Bu telefon numarası zaten kayıtlı';

      final schoolId = schoolIdController.text.isEmpty
          ? selectedSchool?.schoolId ??
              'SCH-${DateTime.now().millisecondsSinceEpoch}'
          : schoolIdController.text;

      final userData = {
        'role': selectedRole,
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
        'phone': phone,
        'schoolName': schoolNameController.text.trim(),
        'schoolId': schoolId,
        'class': classController.text.trim(),
        'studentName': studentNameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').add(userData);
      return null;
    } catch (e) {
      return 'Kullanıcı eklenirken hata oluştu: $e';
    }
  }

  String? textValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return "$fieldName boş olamaz";
    final regex = RegExp(r"^[a-zA-ZçÇşŞğĞüÜöÖıİ\s]+$");
    if (!regex.hasMatch(value.trim())) return "$fieldName yalnızca harf içerebilir";
    return null;
  }

  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    schoolNameController.dispose();
    schoolIdController.dispose();
    classController.dispose();
    studentNameController.dispose();
  }
}
