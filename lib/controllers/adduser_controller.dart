import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/school_model.dart';

class AddUserController {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final studentNameController = TextEditingController();
  final studentClassController = TextEditingController();

  final List<String> roles = ['Veli', 'Öğretmen'];
  String? selectedRole;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Schools> allowedSchools = [];
  Schools? selectedSchool;

  void setAllowedSchools(List<Schools> schools) {
    allowedSchools = schools;
    selectedSchool = allowedSchools.isNotEmpty ? allowedSchools.first : null;
  }

  void onSchoolSelected(Schools? school) {
    selectedSchool = school;
  }

  /// Yeni kullanıcıyı Firestore'a ekler
  Future<String?> addUser() async {
    try {
      final phone = phoneController.text.trim();
      final name = nameController.text.trim();
      final studentName = studentNameController.text.trim();
      final studentClass = studentClassController.text.trim();

      final newUserRef = _firestore.collection('users').doc();

      // Öğrenci bilgileri Map olarak ekleniyor
      final Map<String, String> studentMap = {};
      if (studentName.isNotEmpty && studentClass.isNotEmpty) {
        studentMap[studentClass] = studentName;
      }

      final userData = {
        'userid': newUserRef.id,
        'role': selectedRole,
        'name': name,
        'password': passwordController.text.trim(),
        'phone': phone,
        'schoolId': selectedSchool?.schoolId,
        'schoolName': selectedSchool?.schoolName ?? '',
        'studentNames': studentMap,
        'studentclasses': studentClass.isNotEmpty ? [studentClass] : [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      final batch = _firestore.batch();
      batch.set(newUserRef, userData);

      // Sadece veli ekleniyorsa okul verisini de güncelle
      if (selectedRole == 'Veli' && selectedSchool != null && studentName.isNotEmpty && studentClass.isNotEmpty) {
        final schoolRef = _firestore.collection('schools').doc(selectedSchool!.schoolId);

        // Mevcut sınıflar ve öğrenciler Map yapısına göre güncelleniyor
        final classesMap = selectedSchool!.classes ?? {};
        if (!classesMap.containsKey(studentClass)) {
          classesMap[studentClass] = [];
        }
        classesMap[studentClass]!.add(studentName);

        batch.update(schoolRef, {
          'classes': classesMap,
        });
      }

      await batch.commit();
      return null;
    } catch (e) {
      return 'Kullanıcı eklenirken bir hata oluştu: $e';
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
    passwordController.dispose();
    phoneController.dispose();
    studentNameController.dispose();
    studentClassController.dispose();
  }
}
