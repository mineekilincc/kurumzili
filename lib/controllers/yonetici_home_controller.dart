import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kurumzili/model/school_model.dart';
import 'package:kurumzili/model/user_model.dart';
import 'package:kurumzili/views/adduser_page.dart';
import 'package:kurumzili/views/profile_page.dart';
import 'package:kurumzili/views/siniflarhome_page.dart';
import 'package:kurumzili/views/yoneticihome_page.dart';

class YoneticiHomeController {
  final Users user;
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
  List<Users> parents = [];
  Users? selectedParent;

  List<Schools> allowedSchools = [];
  Schools? selectedSchool;

  YoneticiHomeController({required this.user, required this.onStateChanged}) {
    nameController.text = user.name ?? '';
    schoolNameController.text = user.schoolName ?? '';
    phoneController.text = user.phone ?? '';
    passwordController.text = user.password ?? '';
  }

  /// Yöneticinin izinli olduğu okulları çek
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

      if (allowedSchools.isNotEmpty) {
        selectedSchool = allowedSchools.first;
        await fetchParentsForSelectedSchool();
      }

      onStateChanged();
    } catch (e) {
      debugPrint("Okul verileri çekilirken hata: $e");
      allowedSchools = [];
    }
  }

  /// Seçili okula ait velileri çek (DÜZELTİLMİŞ FONKSİYON)
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

      // ***** DEĞİŞİKLİK BURADA BAŞLIYOR *****
      parents = querySnapshot.docs.map((doc) {
        // doc.data() ile belge içindeki verileri bir Map olarak alıyoruz.
        final data = doc.data();

        // EN ÖNEMLİ ADIM: Belgenin kendi ID'sini 'userid' anahtarıyla map'e ekliyoruz.
        // Users.fromJson metodu bu anahtarı okuyarak doğru ID'yi alacak.
        data['userid'] = doc.id;

        return Users.fromJson(data);
      }).toList();
      // ***** DEĞİŞİKLİK BURADA BİTİYOR *****

      // Alfabetik sırala
      parents.sort((a, b) {
        final nameA = a.name?.toLowerCase() ?? '';
        final nameB = b.name?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      onStateChanged();
    } catch (e) {
      debugPrint("Veli verileri çekilirken hata: $e");
      parents = [];
    }
  }

  /// Okul seçim değiştiğinde çalışır
  Future<void> changeSelectedSchool(Schools school) async {
    selectedSchool = school;
    selectedParent = null;
    await fetchParentsForSelectedSchool();
  }

  /// Eş ekleme işlemi
  Future<void> addSpouse(String spouseName, String spousePhone) async {
    if (selectedParent == null) return;

    final parentQuery = await _firestore
        .collection('users')
        .where('phone', isEqualTo: selectedParent!.phone)
        .limit(1)
        .get();

    if (parentQuery.docs.isEmpty) {
      debugPrint("Hata: Mevcut veli veritabanında bulunamadı.");
      return;
    }

    final parentDocRef = parentQuery.docs.first.reference;
    final newSpouseDocRef = _firestore.collection('users').doc();
    final batch = _firestore.batch();

    final newSpouseData = {
      'userid': newSpouseDocRef.id,
      'role': 'Veli',
      'name': spouseName,
      'phone': spousePhone,
      'schoolName': selectedParent!.schoolName,
      'schoolId': selectedParent!.schoolId,
      'studentNames': selectedParent!.studentNames,
      'studentclasses': selectedParent!.studentclasses,
      'spouseName': selectedParent!.name,
      'spousePhone': selectedParent!.phone,
      'createdAt': FieldValue.serverTimestamp(),
    };

    batch.set(newSpouseDocRef, newSpouseData);
    batch.update(parentDocRef, {
      'spouseName': spouseName,
      'spousePhone': spousePhone,
    });

    await batch.commit();
    await fetchParentsForSelectedSchool();
  }

  /// Kardeş ekleme işlemi
  Future<void> addSibling(String siblingName, String siblingClass) async {
    if (selectedParent == null) return;

    final parentQuery = await _firestore
        .collection('users')
        .where('phone', isEqualTo: selectedParent!.phone)
        .limit(1)
        .get();

    if (parentQuery.docs.isEmpty) {
      debugPrint("Hata: Veli bulunamadı.");
      return;
    }

    final parentDoc = parentQuery.docs.first;
    final parentData = parentDoc.data();

    // Velinin öğrenci listesi (Map<String, String>)
    final updatedStudentNames = Map<String, String>.from(
      parentData['studentNames'] ?? {},
    );
    updatedStudentNames[siblingClass] = siblingName;

    final updatedStudentClasses = List<String>.from(
      parentData['studentclasses'] ?? [],
    );
    if (!updatedStudentClasses.contains(siblingClass)) {
      updatedStudentClasses.add(siblingClass);
    }

    final batch = _firestore.batch();

    // 1. Veli dokümanını güncelle
    batch.update(parentDoc.reference, {
      'studentNames': updatedStudentNames,
      'studentclasses': updatedStudentClasses,
    });

    // 2. Varsa, eşini de güncelle
    if (parentData['spousePhone'] != null &&
        (parentData['spousePhone'] as String).isNotEmpty) {
      final spouseQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: parentData['spousePhone'])
          .limit(1)
          .get();

      if (spouseQuery.docs.isNotEmpty) {
        batch.update(spouseQuery.docs.first.reference, {
          'studentNames': updatedStudentNames,
          'studentclasses': updatedStudentClasses,
        });
      }
    }

    // 3. Okul dokümanını güncelle (Map<String, List<String>> yapısına uygun)
    final schoolRef = _firestore
        .collection('schools')
        .doc(selectedSchool!.schoolId);
    final classesMap = Map<String, dynamic>.from(selectedSchool!.classes ?? {});
    if (classesMap.containsKey(siblingClass)) {
      classesMap[siblingClass] = List<String>.from(classesMap[siblingClass])
        ..add(siblingName);
    } else {
      classesMap[siblingClass] = [siblingName];
    }
    batch.update(schoolRef, {'classes': classesMap});

    await batch.commit();
    await fetchParentsForSelectedSchool();
  }

  /// Alt menü tıklamaları
  void onItemTapped(BuildContext context, int index) {
    selectedIndex = index;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => YoneticihomePage(user: user)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AddUserPage(initialRole: null, allowedSchools: allowedSchools),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SiniflarHomePage(user: user)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
        );
        break;
    }

    onStateChanged();
  }

  // BU DÜZELTİLMİŞ FONKSİYONU yonetici_home_controller.dart DOSYASINA EKLEYİN

  /// Velinin, eşinin ve çocuklarının tüm bilgilerini güncelle
  Future<void> updateParentFullInfo(
    String parentName,
    String parentPhone,
    String spouseName,
    String spousePhone,
    Map<String, String> children, // Map<className, studentName>
  ) async {
    if (selectedParent == null || selectedParent!.userid == null) return;

    final parentDocRef = _firestore
        .collection('users')
        .doc(selectedParent!.userid);

    // Firestore güncellemesi
    await parentDocRef.update({
      'name': parentName,
      'phone': parentPhone,
      'spouseName': spouseName.isNotEmpty ? spouseName : null,
      'spousePhone': spousePhone.isNotEmpty ? spousePhone : null,
      'studentNames': children,
    });

    // Eş varsa ve phone bilgisi varsa eş dokümanını da güncelle
    if (selectedParent!.spousePhone != null &&
        selectedParent!.spousePhone!.isNotEmpty) {
      final spouseQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: selectedParent!.spousePhone)
          .limit(1)
          .get();

      if (spouseQuery.docs.isNotEmpty) {
        await spouseQuery.docs.first.reference.update({
          'studentNames': children,
        });
      }
    }

    // Local model güncellemesi
    selectedParent!.name = parentName;
    selectedParent!.phone = parentPhone;
    selectedParent!.spouseName = spouseName;
    selectedParent!.spousePhone = spousePhone;
    selectedParent!.studentNames = children;

    // Arayüzü güncelle
    onStateChanged();
  }
}
