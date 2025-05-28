import 'package:dio/dio.dart';
import '../model/user_setting_dto.dart';
import '../util/dio.dart';

class UserSettingApi {
  final Dio _dio = DioClient().dio;
  String baseUrl = const String.fromEnvironment('SERVER_URL');

  Future<UserSettingDto?> getUserSetting() async {
    try {
      final response = await _dio.get('$baseUrl/api/user/setting');
      if (response.statusCode == 200) {
        return UserSettingDto.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting user setting: $e');
      return null;
    }
  }

  Future<bool> updateUserSetting(UserSettingDto setting) async {
    try {
      final response = await _dio.put('$baseUrl/api/user/setting', data: setting.toJson());
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user setting: $e');
      return false;
    }
  }
} 