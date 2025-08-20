class SchoolModel {
  final String schoolId;
  final String schoolName;
  final List<String> classes;
  final Map<String, List<String>> students;

  SchoolModel({
    required this.schoolId,
    required this.schoolName,
    required this.classes,
    required this.students,
  });

  /// Firestore dokümanından SchoolModel oluştur
  factory SchoolModel.fromMap(Map<String, dynamic> map, String docId) {
    // Sınıflar listesi
    final classList = List<String>.from(map['classes'] ?? []);

    // Öğrenciler map'i, her value bir liste olacak şekilde
    final studentsMap = <String, List<String>>{};
    if (map['students'] != null && map['students'] is Map) {
      final rawStudents = Map<String, dynamic>.from(map['students']);
      rawStudents.forEach((key, value) {
        if (value is List) {
          studentsMap[key] = List<String>.from(value);
        } else if (value is String) {
          studentsMap[key] = [value];
        }
      });
    }

    return SchoolModel(
      schoolId: map['schoolId'] ?? docId,
      schoolName: map['schoolName'] ?? '',
      classes: classList,
      students: studentsMap,
    );
  }

  /// SchoolModel'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'schoolId': schoolId,
      'schoolName': schoolName,
      'classes': classes,
      'students': students,
    };
  }

  /// Dropdown ve karşılaştırmalar için eşitlik
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolModel &&
          runtimeType == other.runtimeType &&
          schoolId == other.schoolId;

  @override
  int get hashCode => schoolId.hashCode;
}
