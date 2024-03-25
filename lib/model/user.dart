class User {
  String? name;
  String? role;

  User({this.name, this.role});


  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      role: map['role'],
    );
  }

  // User 객체에서 Map으로 변환
  Map<String, String?> toMap() {
    return {
      'name': name,
      'role': role,
    };
  }
}