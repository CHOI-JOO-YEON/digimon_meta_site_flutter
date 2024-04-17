import 'package:json_annotation/json_annotation.dart';

class LoginResponseDto{
  final String nickname;
  final String role;
  final int userNo;

  LoginResponseDto({required this.nickname, required this.role, required this.userNo});
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'role': role,
      'userNo': userNo,
    };
  }

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      nickname: json['nickname'],
      role: json['role'],
      userNo: json['userNo'],
    );
  }
}