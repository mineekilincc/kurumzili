class Users {
  String? userid;
  String? password;
  String? role;
  String? phone;
  String? schoolId;
  String? name;
  String? surname;
  String? schoolName;
  String? userNames;
  String? childOfPhone;
  String? spouseId;      // yeni
  String? spouseName;    // yeni
  String? spousePhone;   // yeni
  List<String> allowedSchoolIds;
  Map<String, String>? studentNames; // Sınıf -> Öğrenci adı
  List<String>? studentclasses;      // Sınıflar listesi

  Users({
    this.userid,
    this.password,
    this.role,
    this.phone,
    this.schoolId,
    this.name,
    this.surname,
    this.schoolName,
    this.userNames,
    this.childOfPhone,
    this.spouseId,
    this.spouseName,
    this.spousePhone,
    List<String>? allowedSchoolIds,
    this.studentNames,
    this.studentclasses,
  }) : allowedSchoolIds = allowedSchoolIds ?? [];

  Users.fromJson(Map<String, dynamic> json)
    : userid = json['userid']?.toString(),
      password = json['password']?.toString(),
      role = json['role']?.toString(),
      phone = json['phone']?.toString(),
      schoolId = json['schoolId']?.toString(),
      name = json['name']?.toString(),
      surname = json['surname']?.toString(),
      schoolName = json['schoolName']?.toString(),
      userNames = json['userNames']?.toString(),
      childOfPhone = json['childOfPhone']?.toString(),
      spouseId = json['spouseId']?.toString(),
      spouseName = json['spouseName']?.toString(),
      spousePhone = json['spousePhone']?.toString(),
      allowedSchoolIds = List<String>.from(json['allowedSchoolIds'] ?? []),
      studentNames = (json['studentNames'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
          {},
      studentclasses = (json['studentclasses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'password': password,
      'role': role,
      'phone': phone,
      'schoolId': schoolId,
      'name': name,
      'surname': surname,
      'schoolName': schoolName,
      'userNames': userNames,
      'childOfPhone': childOfPhone,
      'spouseId': spouseId,
      'spouseName': spouseName,
      'spousePhone': spousePhone,
      'allowedSchoolIds': allowedSchoolIds,
      'studentNames': studentNames,
      'studentclasses': studentclasses,
    };
  }
}
