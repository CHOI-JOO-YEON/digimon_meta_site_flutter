import 'package:digimon_meta_site_flutter/model/use_card_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/used_card_info.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/type.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';

import '../model/note.dart';

class CardApi {
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();
  CardDataService cardDataService = CardDataService();

  Future<CardResponseDto> getCardsBySearchParameter(
      SearchParameter searchParameter) async {
    try {
      await cardDataService.initialize();
      return cardDataService.searchCards(searchParameter);
    } catch (e) {
      print('Error searching cards: $e');
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

  Future<List<TypeDto>> getTypes() async {
    try {
      var response = await dioClient.dio.get('$baseUrl/api/card/types');
      if (response.statusCode == 200) {
        return TypeDto.fromJsonList(response.data);
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching cards');
    }
  }

  Future<UseCardResponseDto> getUseCard(int id) async {
    try {
      var response = await dioClient.dio
          .get('$baseUrl/api/card/use', queryParameters: {'cardImgId': id});
      if (response.statusCode == 200) {
        return UseCardResponseDto.fromJson(response.data);
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching cards');
    }
  }
}
