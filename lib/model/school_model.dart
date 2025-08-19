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

  factory SchoolModel.fromMap(Map<String, dynamic> map, String docId) {
    // classes listesi
    final classList = List<String>.from(map['classes'] ?? []);

    // students map'i, her value bir liste olacak şekilde
    final studentsMap = <String, List<String>>{};
    if (map['students'] != null) {
      final rawStudents = Map<String, dynamic>.from(map['students']);
      rawStudents.forEach((key, value) {
        // her öğrenci listesi olarak parse ediliyor
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
}
