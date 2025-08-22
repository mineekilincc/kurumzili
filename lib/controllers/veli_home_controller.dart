import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../views/profile_page.dart';
import '../views/qrscan_page.dart';

class VeliHomeController {
  final Users user;
  int selectedIndex = 0;
  final VoidCallback onStateChanged;

  List<String> studentNames = [];
  String? selectedStudent;
  String? selectedStudentClass;

  VeliHomeController({required this.user, required this.onStateChanged}) {
    fetchStudents();
  }

  /// Öğrencileri çek ve varsayılan seçim yap
  void fetchStudents() {
    // Map<String, String> -> [isimler]
    studentNames = user.studentNames?.values.toList() ?? [];

    if (studentNames.isNotEmpty) {
      selectedStudent = studentNames.first;
      selectedStudentClass = user.studentNames?.entries
          .firstWhere(
            (entry) => entry.value == selectedStudent,
            orElse: () => const MapEntry('Bilinmiyor', ''),
          )
          .key;
    }

    onStateChanged();
  }

  /// Dropdowndan öğrenci seçildiğinde
  void onStudentSelected(String? studentName) {
    if (studentName != null) {
      selectedStudent = studentName;
      selectedStudentClass = user.studentNames?.entries
          .firstWhere(
            (entry) => entry.value == studentName,
            orElse: () => const MapEntry('Bilinmiyor', ''),
          )
          .key;
      onStateChanged();
    }
  }

  /// Alt menü tıklamaları
  void onItemTapped(BuildContext context, int index) {
    selectedIndex = index;
    switch (index) {
      case 1:
        if (selectedStudent != null && selectedStudentClass != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QRScanPage(
                user: user,
                selectedStudentName: selectedStudent,
                selectedStudentClass: selectedStudentClass,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen önce öğrenci seçin.')),
          );
        }
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(user: user),
          ),
        );
        break;
    }
    onStateChanged();
  }

  void dispose() {}
}
