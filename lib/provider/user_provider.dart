import 'package:flutter/material.dart';

import '../model/user.dart';

class UserProvider with ChangeNotifier {
  User _user = User();

  User get user => _user;

  // 사용자 로그인 정보를 설정하는 메서드
  void setUser(String token, String name, String role) {
    _user = User(token: token, name: name, role: role);
    notifyListeners(); // 소비자에게 변경 사항을 알립니다.
  }

  // 사용자 로그아웃 메서드
  void logout() {
    _user = User();
    notifyListeners(); // 소비자에게 변경 사항을 알립니다.
  }
}