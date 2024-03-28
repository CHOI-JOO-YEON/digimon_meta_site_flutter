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
  bool _isLogin = false;

  bool get isLogin => _isLogin;
  UserProvider() {
    _loadUser();
  }

  void saveUserInfoToLocalStorage(String nickname, String role) {
    html.window.localStorage['nickname'] = nickname;
    html.window.localStorage['role'] = role;
  }

  Future<bool> loginCheck() async {
    bool isLogin = await UserApi().isLogin();
    if(!isLogin) {
      logout();
    }
    return isLogin;
  }

  Future<void> _loadUser() async {
    _nickname = html.window.localStorage['nickname'];
    _role = html.window.localStorage['role'];
    if(_nickname!=null) {
      _isLogin=true;
    }
    notifyListeners();
  }

  Future<void> setUser(LoginResponseDto loginResponseDto) async {
    _nickname = loginResponseDto.nickname;
    _role = loginResponseDto.role;
    saveUserInfoToLocalStorage(_nickname!, _role!);
    _isLogin=true;
    notifyListeners();
  }

  Future<void> logout() async {
    bool isLogout = await UserApi().logout();
    if(isLogout){
      _nickname = null;
      _role = null;
      html.window.localStorage.remove('nickname');
      html.window.localStorage.remove('role');
      _isLogin=false;
      notifyListeners();
    }

  }

  Future<void> unAuth() async {
    _nickname = null;
    _role = null;
    html.window.localStorage.remove('nickname');
    html.window.localStorage.remove('role');
    _isAuthError=true;
    _isLogin=false;
    notifyListeners();
  }


  bool hasManagerRole() {
    return _role == 'MANAGER' || _role == 'ADMIN';
  }


}
