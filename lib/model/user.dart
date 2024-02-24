class User {
  String? token;
  String? name;
  String? role;

  User({this.token, this.name, this.role});


  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      token: map['token'],
      name: map['name'],
      role: map['role'],
    );
  }

  // User 객체에서 Map으로 변환
  Map<String, String?> toMap() {
    return {
      'token': token,
      'name': name,
      'role': role,
    };
  }
}