import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';
import 'package:dio/dio.dart';

import '../model/account/login_response_dto.dart';
import '../model/note.dart';
import '../model/user.dart';

class UserApi{
  String baseUrl = 'http://localhost:8080';
  DioClient dioClient = DioClient();


  Future<LoginResponseDto?> oauthLogin(String code) async {
    final response = await dioClient.dio.get('$baseUrl/api/account/token/kakao'
        ,queryParameters: {
          'code': code
        }
    );
    if(response.statusCode==200){
      return LoginResponseDto.fromJson(response.data);
    }
    return null;
  }

  Future<bool> isLogin() async {
    final response = await dioClient.dio.get('$baseUrl/api/user/token/validate'
    );
    if(response.statusCode==200){
      return true;
    }
    return false;
  }
  Future<LoginResponseDto?> usernameLogin(String username, String password) async {
    final response = await dioClient.dio.post('$baseUrl/api/account/login/username'
        ,data: {
          'username': username,
          'password': password
        }
    );
    if(response.statusCode==200){
      var loginResponseDto = LoginResponseDto.fromJson(response.data);
      return loginResponseDto;

    }
    return null;
  }

}