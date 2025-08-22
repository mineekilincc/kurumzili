import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/school_model.dart';
import '../model/user_model.dart';
import '../views/adduser_page.dart';
import '../views/profile_page.dart';

class YoneticiHomeController {
  final Users user;
  final VoidCallback onStateChanged;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int selectedIndex = 0;

  List<Schools> allowedSchools = [];
  Schools? selectedSchool;

  YoneticiHomeController({
    required this.user,
    required this.onStateChanged,
  });

  /// Firestore'dan yöneticinin görebileceği okulları getirir
  Future<void> fetchAllowedSchools() async {
    if (user.allowedSchoolIds.isEmpty) {
      allowedSchools = [];
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('schools')
          .where(FieldPath.documentId, whereIn: user.allowedSchoolIds)
          .get();

      allowedSchools = snapshot.docs
          .map((doc) => Schools.fromMap(doc.data(), doc.id))
          .toList();

      // Varsayılan ilk okul seç
      if (allowedSchools.isNotEmpty) {
        selectedSchool = allowedSchools.first;
      }

      onStateChanged();
    } catch (e) {
      debugPrint("Okul verileri çekilirken hata: $e");
      allowedSchools = [];
    }
  }

  /// Sayfa altındaki bottom nav tıklamaları
  void onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      selectedIndex = 0;
      onStateChanged();
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddUserPage(
            initialRole: null,
            allowedSchools: allowedSchools,
          ),
        ),
      );
    }

    if (index == 2) {
      // Bu sayfada zaten Sınıflar sayfasındayız, geçiş yapılmaz
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
      );
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      selectedIndex = 0;
      onStateChanged();
    });
  }

  void dispose() {
    // eğer başka controller'lar eklenirse burada dispose edilmeli
  }
}
