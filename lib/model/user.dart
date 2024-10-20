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

  Map<String, String?> toMap() {
    return {
      'name': name,
      'role': role,
    };
  }
}