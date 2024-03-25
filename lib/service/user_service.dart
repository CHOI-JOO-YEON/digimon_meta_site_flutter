
import 'dart:html' as html;

import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/user_api.dart';
import '../model/account/login_response_dto.dart';

class UserService{

  UserApi userApi = UserApi();


  Future<bool> oauthLogin(String code, BuildContext context) async {
    try{
      LoginResponseDto? loginResponseDto = await userApi.oauthLogin(code);
      if(loginResponseDto==null){
        return false;
      }
      Provider.of<UserProvider>(context, listen: false).setUser(loginResponseDto);
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

}