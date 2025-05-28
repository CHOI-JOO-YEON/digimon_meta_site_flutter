import 'dart:html' as html;
import 'dart:async';

import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/user_api.dart';
import '../model/account/login_response_dto.dart';
import '../service/user_setting_service.dart';

class UserService{

  UserApi userApi = UserApi();


  Future<bool> oauthLogin(String code, BuildContext context) async {
    try{
      LoginResponseDto? loginResponseDto = await userApi.oauthLogin(code);
      if(loginResponseDto==null){
        return false;
      }
      Provider.of<UserProvider>(context, listen: false).setUser(loginResponseDto);
      
      // 로그인 성공 시 사용자 설정 로드
      try {
        final userSetting = await UserSettingService().loadUserSetting(context);
        await UserSettingService().applyUserSetting(context, userSetting);
      } catch (e) {
        print('Failed to load user settings: $e');
        // 설정 로드 실패해도 로그인은 성공으로 처리
      }
    }catch(e){
      return false;
    }
    return true;
  }
  Future<bool> usernameLogin(String username, String password) async{
    try{
      LoginResponseDto? loginResponseDto = await userApi.usernameLogin(username,password);
      if(loginResponseDto==null){
        return false;
      }
      html.window.localStorage['nickname'] = loginResponseDto.nickname;
      html.window.localStorage['role'] = loginResponseDto.role;
    }catch(e){
      return false;
    }
    return true;
  }

  Future<bool> logoutWithPopup(BuildContext context) async {
    // 로그아웃 팝업 URL
    String baseUrl = const String.fromEnvironment('SERVER_URL');
    String url = '$baseUrl/api/logout';
    String windowName = 'Logout';
    String windowFeatures = 'width=800,height=600';
    
    // 메시지 이벤트 핸들러 추가
    final completer = Completer<bool>();
    
    html.window.addEventListener('message', (event) {
      html.MessageEvent messageEvent = event as html.MessageEvent;
      var success = messageEvent.data['logout_success'];
      
      if (success != null) {
        if (success == true) {
          // 로그아웃 성공 처리
          Provider.of<UserProvider>(context, listen: false).unAuth();
          
          // 사용자 설정 초기화 (서버 설정만 제거, 로컬 설정은 유지)
          // 필요시 UserSettingService().clearSettings(); 호출 가능
          
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      }
    });
    
    // 팝업 열기
    html.window.open(url, windowName, windowFeatures);
    
    return completer.future;
  }
}