
import 'package:digimon_meta_site_flutter/util/dio.dart';
import '../model/limit_dto.dart';

class LimitApi {
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();

  Future<List<LimitDto>?> getLimits() async {
    try {

      var response =
      await dioClient.dio.get('$baseUrl/api/limit');
      if (response.statusCode == 200) {
        return LimitDto.fromJsonList(response.data);
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

}
