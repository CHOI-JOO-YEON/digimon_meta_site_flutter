import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';
import 'package:dio/dio.dart';

import '../model/note.dart';

class CardApi{

  String baseUrl = 'http://localhost:8080';
  Dio dio = DioClient().dio;

  Future<CardResponseDto> getCardsBySearchParameter(SearchParameter searchParameter) async {
    print(searchParameter);
    try {
      var response = await dio.get('$baseUrl/card/search', queryParameters: searchParameter.toJson());
      if (response.statusCode == 200) {
        return CardResponseDto.fromJson(response.data);

      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching cards');
    }

  }

  Future<List<NoteDto>> getNotes() async {
    try {
      var response = await dio.get('$baseUrl/card/note');
      if (response.statusCode == 200) {
        return NoteDto.fromJsonList(response.data);

      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching cards');
    }

  }

}