import 'package:digimon_meta_site_flutter/api/user_api.dart';
import 'package:digimon_meta_site_flutter/model/account/login_response_dto.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';
import 'dart:html' as html;

class UserProvider with ChangeNotifier {
  String? _nickname;
  String? _role;
  int? _userNo;
  bool _isAuthError = false;

  String? get nickname => _nickname;

  String? get role => _role;
  int? get userNo => _userNo;
  bool get isAuthError => _isAuthError;
  bool _isLogin = false;

  bool get isLogin => _isLogin;
  UserProvider() {
    _loadUser();
  }

  void saveUserInfoToLocalStorage(String nickname, String role, int userNo) {
    html.window.localStorage['nickname'] = nickname;
    html.window.localStorage['role'] = role;
    html.window.localStorage['userNo'] = userNo.toString();
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
    _userNo = int.parse( html.window.localStorage['userNo']??'0');
    if(_nickname!=null) {
      _isLogin=true;
    }
    notifyListeners();
  }

  Future<void> setUser(LoginResponseDto loginResponseDto) async {
    _nickname = loginResponseDto.nickname;
    _role = loginResponseDto.role;
    _userNo = loginResponseDto.userNo;
    saveUserInfoToLocalStorage(_nickname!, _role!,_userNo!);
    _isLogin=true;
    notifyListeners();
  }

  void clearKakaoAuth() {
    // Clear cookies that might be related to Kakao auth
    final cookies = html.document.cookie!.split(';');
    for (var cookie in cookies) {
      final parts = cookie.trim().split('=');
      final name = parts[0];
      if (name.contains('kakao') || name.contains('_kp') || name.contains('_ka')) {
        final path = '/';
        html.document.cookie = '$name=; path=$path; expires=Thu, 01 Jan 1970 00:00:00 GMT';
      }
    }
  }

  Future<void> logout() async {
    bool isLogout = await UserApi().logout();
    if(isLogout){
      clearKakaoAuth();
      _nickname = null;
      _role = null;
      html.window.localStorage.remove('nickname');
      html.window.localStorage.remove('role');
      html.window.localStorage.remove('userNo');
      _isLogin=false;
      notifyListeners();
    }
  }

  Future<void> unAuth() async {
    clearKakaoAuth();
    _nickname = null;
    _role = null;
    html.window.localStorage.remove('nickname');
    html.window.localStorage.remove('role');
    html.window.localStorage.remove('userNo');
    _isAuthError=true;
    _isLogin=false;
    notifyListeners();
  }


  bool hasManagerRole() {
    return _role == 'MANAGER' || _role == 'ADMIN';
  }


}
