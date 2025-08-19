import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/school_model.dart';

class AddUserController {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final schoolNameController = TextEditingController();
  final schoolIdController = TextEditingController();
  final classController = TextEditingController();
  final studentNameController = TextEditingController();

  final List<String> roles = ['Veli', 'Öğrenci', 'Yönetici'];
  String? selectedRole;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SchoolModel> schools = [];
  SchoolModel? selectedSchool;

  String? selectedClass;
  String? selectedStudent;

  List<String> filteredClasses = [];
  List<String> filteredStudents = [];

  Future<void> fetchSchools() async {
    final querySnapshot = await _firestore.collection('schools').get();
    schools = querySnapshot.docs
        .map((doc) => SchoolModel.fromMap(doc.data(), doc.id))
        .where((school) => school.schoolName.isNotEmpty)
        .toList();

    if (schools.isNotEmpty) {
      selectedSchool = schools.first;
      filteredClasses = selectedSchool!.classes;
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
      final schoolId = schoolIdController.text.isEmpty
          ? 'SCH-${DateTime.now().millisecondsSinceEpoch}'
          : schoolIdController.text;

      final userData = {
        'role': selectedRole,
        'name': nameController.text,
        'surname': surnameController.text,
        'username': usernameController.text,
        'password': passwordController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'schoolName': schoolNameController.text,
        'schoolId': schoolId,
        'class': classController.text,
        'studentName': studentNameController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').add(userData);
      return null;
    } catch (e) {
      return 'Kullanıcı eklenirken hata oluştu: $e';
    }
  }

  String? validateTurkish(String? value, String fieldName) {
    if (value == null || value.isEmpty) return "$fieldName boş olamaz";
    final regex = RegExp(r"^[a-zA-ZÇŞĞÜÖİçşğüöı\s]+$");
    if (!regex.hasMatch(value)) return "$fieldName yalnızca harf içerebilir";
    return null;
  }

  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    schoolNameController.dispose();
    schoolIdController.dispose();
    classController.dispose();
    studentNameController.dispose();
  }
}
