class Users {
  String? password;
  String? role;
  int? phone;
  String? schoolId;
  String? name;
  String? surname;
  String? schoolName;
  String? email;
  String? username;

  Users(
      {this.password,
      this.role,
      this.phone,
      this.schoolId,
      this.name,
      this.surname,
      this.schoolName,
      this.email,
      this.username});

  Users.fromJson(Map<String, dynamic> json) {
    password = json['password']?.toString();
    role = json['role']?.toString();

    final phoneValue = json['phone'];
    if (phoneValue != null) {
      if (phoneValue is int) {
        phone = phoneValue;
      } else if (phoneValue is String) {
        phone = int.tryParse(phoneValue);
      }
    }

    schoolId = json['schoolId']?.toString();
    name = json['name']?.toString();
    surname = json['surname']?.toString();
    schoolName = json['schoolName']?.toString();
    email = json['email']?.toString();
    username = json['username']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['password'] = password;
    data['role'] = role;
    data['phone'] = phone;
    data['schoolId'] = schoolId;
    data['name'] = name;
    data['surname'] = surname;
    data['schoolName'] = schoolName;
    data['email'] = email;
    data['username'] = username;
    return data;
  }
}