import 'package:json_annotation/json_annotation.dart';
part 'login_response_dto.g.dart';
@JsonSerializable()
class LoginResponseDto{
  final String accessToken;
  final String nickname;
  final String role;

  LoginResponseDto({required this.accessToken, required this.nickname, required this.role});
  factory LoginResponseDto.fromJson(Map<String, dynamic> json) => _$LoginResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}