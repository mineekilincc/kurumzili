class Users {
  String? userid;
  String? password;
  String? role;
  String? phone;
  String? schoolId;
  String? name;
  String? surname;
  String? schoolName;
  String? username;
  String? childOfPhone;
  List<String> allowedSchoolIds;
  List<String>? students; // ✅ yeni eklendi
  List<String>? studentclasses;
  

  Users({
    this.password,
    this.role,
    this.phone,
    this.schoolId,
    this.name,
    this.surname,
    this.schoolName,
    this.username,
    this.childOfPhone,
    List<String>? allowedSchoolIds,
    this.students, // ✅ constructor'da
    this.studentclasses,
  }) : allowedSchoolIds = allowedSchoolIds ?? [];

  Users.fromJson(Map<String, dynamic> json)
      : password = json['password']?.toString(),
        role = json['role']?.toString(),
        phone = json['phone']?.toString(),
        schoolId = json['schoolId']?.toString(),
        name = json['name']?.toString(),
        surname = json['surname']?.toString(),
        schoolName = json['schoolName']?.toString(),
        username = json['username']?.toString(),
        childOfPhone = json['childOfPhone']?.toString(),
        allowedSchoolIds = List<String>.from(json['allowedSchoolIds'] ?? []),
        students = json['studentNames'] != null
            ? List<String>.from(json['studentNames'])
            : json['studentName'] != null
                ? [json['studentName']] // tek öğrenci varsa da listeye çevir
                : [], // ✅ fromJson'a eklendi
        studentclasses = json['studentclasses'] != null
            ? List<String>.from(json['studentclasses'])
            : []; // öğrenci sınıfları eklendi

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'role': role,
      'phone': phone,
      'schoolId': schoolId,
      'name': name,
      'surname': surname,
      'username': username,
      'childOfPhone': childOfPhone,
      'allowedSchoolIds': allowedSchoolIds,
      'studentNames': students, // ✅ toJson'a eklendi
      'studentclasses': studentclasses,
    };
  }
}
