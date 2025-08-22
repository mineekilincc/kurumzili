import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/school_model.dart';

class MainManagerHomeController {
  List<Users> managers = [];
  List<Schools> allSchools = [];
  List<Schools> selectedSchools = [];

  Users? selectedManager;

  /// Firestore’dan yöneticileri ve okulları yükle
  Future<void> loadManagersAndSchools() async {
    try {
      // Yönetici kullanıcılar
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Yönetici')
          .get();
      managers = userSnapshot.docs
          .map((doc) {
            final user = Users.fromJson(doc.data());
            user.userid = doc.id;
            return user;
          })
          .toList();

      // Okullar
      final schoolSnapshot =
          await FirebaseFirestore.instance.collection('schools').get();
      allSchools = schoolSnapshot.docs
          .map((doc) => Schools.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Veri çekilirken hata: $e');
    }
  }

  /// Yönetici seçildiğinde onun okullarını yükle
  void loadSelectedSchoolsForManager() {
    if (selectedManager != null) {
      selectedSchools = allSchools
          .where(
              (s) => selectedManager!.allowedSchoolIds.contains(s.schoolId))
          .toList();
    } else {
      selectedSchools = [];
    }
  }

  /// Checkbox toggle
  void toggleSchool(Schools school) {
    if (selectedSchools.contains(school)) {
      selectedSchools.remove(school);
    } else {
      selectedSchools.add(school);
    }
  }

  /// Seçilen okulları kaydet
  Future<void> saveSelections() async {
    if (selectedManager == null) {
      throw Exception('Önce bir yönetici seçin.');
    }

    final schoolIds = selectedSchools.map((s) => s.schoolId).toList();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(selectedManager!.userid)
          .update({'allowedSchoolIds': schoolIds});
    } catch (e) {
      throw Exception('Kaydetme hatası: $e');
    }
  }
}
