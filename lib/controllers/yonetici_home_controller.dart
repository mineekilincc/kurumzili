import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kurumzili/model/school_model.dart';
import 'package:kurumzili/model/user_model.dart';
import 'package:kurumzili/views/adduser_page.dart';
import 'package:kurumzili/views/profile_page.dart';

class YoneticiHomeController {
  final Users user;
  String _searchQuery = '';

  final VoidCallback onStateChanged;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int selectedIndex = 0;

  // Controller'lar
  late final nameController = TextEditingController();
  late final usernameController = TextEditingController();
  late final schoolNameController = TextEditingController();
  late final phoneController = TextEditingController();
  late final passwordController = TextEditingController();

  // Veliler ve okullar
  List<Users> parents = []; // SADECE seçilen okulun velileri
  Users? selectedParent;

  List<SchoolModel> allowedSchools = [];
  SchoolModel? selectedSchool;

  YoneticiHomeController({required this.user, required this.onStateChanged}) {
    nameController.text = user.name ?? '';
    usernameController.text = user.username ?? '';
    schoolNameController.text = user.schoolName ?? '';
    phoneController.text = user.phone ?? '';
    passwordController.text = user.password ?? '';
  }

  /// Yöneticinin izinli olduğu okulları çek
  Future<void> fetchAllowedSchools() async {
    if (user.allowedSchoolIds == null || user.allowedSchoolIds.isEmpty) {
      allowedSchools = [];
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('schools')
          .where(FieldPath.documentId, whereIn: user.allowedSchoolIds)
          .get();

      allowedSchools = snapshot.docs
          .map((doc) => SchoolModel.fromMap(doc.data(), doc.id))
          .toList();

      // Varsayılan olarak ilk okulu seç
      if (allowedSchools.isNotEmpty) {
        selectedSchool = allowedSchools.first;
        await fetchParentsForSelectedSchool();
      }

      onStateChanged();
    } catch (e) {
      allowedSchools = [];
    }
  }

  /// Seçili okula ait velileri çek
  Future<void> fetchParentsForSelectedSchool() async {
    if (selectedSchool == null) {
      parents = [];
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Veli')
          .where('schoolId', isEqualTo: selectedSchool!.schoolId)
          .get();

      parents = querySnapshot.docs
          .map((doc) => Users.fromJson(doc.data()))
          .toList();

      // Alfabetik sırala
      parents.sort((a, b) {
        final nameA = a.name?.toLowerCase() ?? '';
        final nameB = b.name?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      onStateChanged();
    } catch (e) {
      parents = [];
    }
  }

  /// Okul seçim değiştiğinde çalışır
  Future<void> changeSelectedSchool(SchoolModel school) async {
    selectedSchool = school;
    selectedParent = null;
    await fetchParentsForSelectedSchool();
  }

  /// Eş ekleme işlemi
  Future<void> addSpouse(String spouseName, String spousePhone) async {
    if (selectedParent == null) return;

    await _firestore.collection('users').add({
      'role': 'Veli',
      'name': spouseName,
      'phone': spousePhone,
      'childOfPhone': selectedParent!.phone,
      'schoolName': selectedParent!.schoolName,
      'schoolId': selectedParent!.schoolId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await fetchParentsForSelectedSchool(); // Listeyi güncelle
  }

  /// Alt menü tıklamaları
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
          builder: (_) =>
              AddUserPage(initialRole: null, allowedSchools: allowedSchools),
        ),
      );
    }

    if (index == 2) {
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
    nameController.dispose();
    usernameController.dispose();
    schoolNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }
}
