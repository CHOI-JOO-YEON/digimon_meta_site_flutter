
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';

import '../model/note.dart';

class CardApi{

  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();

  Future<CardResponseDto> getCardsBySearchParameter(SearchParameter searchParameter) async {
    try {
      var response = await dioClient.dio.get('$baseUrl/api/card/search', queryParameters: searchParameter.toJson());
      if (response.statusCode == 200) {
        return CardResponseDto.fromJson(response.data);

      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      print(e);
      return CardResponseDto();
    }

  }

  Future<List<NoteDto>> getNotes() async {
    try {
      var response = await dioClient.dio.get('$baseUrl/api/card/note');
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