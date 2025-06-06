import 'package:digimon_meta_site_flutter/api/user_api.dart';
import 'package:digimon_meta_site_flutter/model/account/login_response_dto.dart';
import 'package:digimon_meta_site_flutter/service/user_service.dart';
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
      await UserApi().logout();
      _nickname = null;
      _role = null;
      html.window.localStorage.remove('nickname');
      html.window.localStorage.remove('role');
      html.window.localStorage.remove('userNo');
      _isLogin = false;
      notifyListeners();
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
  Future<void> logout(BuildContext context) async {
    // 새로운 팝업 방식 로그아웃 사용
    await UserService().logoutWithPopup(context);
  }

  Future<void> unAuth() async {
    await UserApi().logout();
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
