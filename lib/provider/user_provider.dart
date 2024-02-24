import 'package:digimon_meta_site_flutter/api/user_api.dart';
import 'package:digimon_meta_site_flutter/model/account/login_response_dto.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';
import 'dart:html' as html;

class UserProvider with ChangeNotifier {
  String? _nickname;
  String? _role;
  bool _isAuthError = false;

  String? get nickname => _nickname;

  String? get role => _role;
  bool get isAuthError => _isAuthError;

  UserProvider() {
    _loadUser();
  }

  void saveUserInfoToLocalStorage(String nickname, String role) {
    html.window.localStorage['nickname'] = nickname;
    html.window.localStorage['role'] = role;
  }

  Future<void> _loadUser() async {
    _nickname = html.window.localStorage['nickname'];
    _role = html.window.localStorage['role'];
    _nickname = '1';
    notifyListeners();
  }

  Future<void> setUser(LoginResponseDto loginResponseDto) async {
    _nickname = loginResponseDto.nickname;
    _role = loginResponseDto.role;
    saveUserInfoToLocalStorage(_nickname!, _role!);
    notifyListeners();
  }

  Future<void> logout() async {
    _nickname = null;
    _role = null;
    html.window.localStorage.remove('nickname');
    html.window.localStorage.remove('role');
    notifyListeners();
  }

  Future<void> unAuth() async {
    _nickname = null;
    _role = null;
    html.window.localStorage.remove('nickname');
    html.window.localStorage.remove('role');
    _isAuthError=true;
    notifyListeners();
  }

  bool isLogin() {
    return _nickname != null;
  }
}
