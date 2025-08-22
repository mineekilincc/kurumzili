class Schools {
  final String schoolId;
  final String schoolName;
  final bool status;
  final String? anons;
  final Map<String, List<String>>? classes; // Sınıf adı -> öğrenci listesi

  Schools({
    required this.schoolId,
    required this.schoolName,
    required this.status,
    this.anons,
    this.classes,
  });

  // Firestore JSON’dan parse
  factory Schools.fromJson(Map<String, dynamic> json) {
    return Schools(
      schoolId: json['schoolId'] ?? '',
      schoolName: json['schoolName'] ?? '',
      status: json['status'] ?? false,
      anons: json['anons'],
      classes: (json['classes'] as Map?)?.map(
        (key, value) => MapEntry(
          key.toString(),
          List<String>.from(value as List<dynamic>),
        ),
      ),
    );
  }

  // Firestore Map + docId ile parse
  factory Schools.fromMap(Map<String, dynamic> map, String docId) {
    return Schools(
      schoolId: map['schoolId'] ?? docId,
      schoolName: map['schoolName'] ?? '',
      status: map['status'] ?? false,
      anons: map['anons'],
      classes: (map['classes'] as Map?)?.map(
        (key, value) => MapEntry(
          key.toString(),
          List<String>.from(value as List<dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolId': schoolId,
      'schoolName': schoolName,
      'status': status,
      'anons': anons,
      'classes': classes,
    };
  }
}
