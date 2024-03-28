import 'package:digimon_meta_site_flutter/model/card_collect_dto.dart';
import 'package:dio/dio.dart';

import '../util/dio.dart';

class CollectApi {
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();

  Future<List<CardCollectDto>?> getCollect() async {
    try {
      final response = await dioClient.dio.get(
          '$baseUrl/api/card-collect');

      if (response.statusCode == 200) {
        return CardCollectDto.fromJsonList(response.data);
      }
    } catch (e) {
      print(e);
    }


    return null;
  }

  Future<bool> postCollect(List<CardCollectDto> list)  async {
    try {
      final response = await dioClient.dio.post(
        '$baseUrl/api/card-collect',
        data: list.map((dto) => dto.toJson()).toList(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}