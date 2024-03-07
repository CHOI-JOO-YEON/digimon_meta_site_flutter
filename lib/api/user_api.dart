import 'package:digimon_meta_site_flutter/util/dio.dart';

import '../model/account/login_response_dto.dart';

class UserApi {
  // String baseUrl = 'http://localhost:8080';
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();

  Future<LoginResponseDto?> oauthLogin(String code) async {
    final response = await dioClient.dio.get('$baseUrl/api/account/token/kakao',
        queryParameters: {'code': code});
    if (response.statusCode == 200) {
      return LoginResponseDto.fromJson(response.data);
    }
    return null;
  }

  Future<bool> isLogin() async {
    try {
      final response =
          await dioClient.dio.get('$baseUrl/api/user/token/validate');
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      return false;
    }

    return false;
  }

  Future<LoginResponseDto?> usernameLogin(
      String username, String password) async {
    final response = await dioClient.dio.post(
        '$baseUrl/api/account/login/username',
        data: {'username': username, 'password': password});
    if (response.statusCode == 200) {
      var loginResponseDto = LoginResponseDto.fromJson(response.data);
      return loginResponseDto;
    }
    return null;
  }
}
