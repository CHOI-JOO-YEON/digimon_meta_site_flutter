import 'dart:convert';

import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/deck_request_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/format.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';
import 'package:intl/intl.dart';

import '../model/deck-build.dart';
import '../model/paged_response_deck_dto.dart';
import '../model/format_deck_count_dto.dart';

class DeckApi {
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();

  Future<DeckView?> postDeck(DeckBuild deck) async {
    try {
      var response = await dioClient.dio
          .post('$baseUrl/api/deck', data: DeckRequestDto(deck).toJson());
      if (response.statusCode == 200) {
        return DeckView.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      print(e);
      // throw Exception('Error occurred while fetching cards');
    }
  }

  Future<DeckView?> importDeck(Map<String, int> deckCode) async {
    try {
      var response = await dioClient.dio
          .post('$baseUrl/api/deck/import', data: {'deck': deckCode});
      if (response.statusCode == 200) {
        return DeckView.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  Future<DeckView?> importDeckThisSite(Map<String, dynamic> deckCode) async {
    try {
      var response = await dioClient.dio
          .post('$baseUrl/api/deck/import/this', data: {'deck': deckCode});
      if (response.statusCode == 200) {
        return DeckView.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }
  
  Future<DeckView?> importDeckQr(String deckMapString) async {
    try {
      var response = await dioClient.dio
          .get('$baseUrl/api/deck/import/qr', queryParameters: {
            'deck': deckMapString
      });
      if (response.statusCode == 200) {
        return DeckView.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  Map<DigimonCard, int> parseJsonToCardAndCntMap(String jsonString) {
    final parsedJson = json.decode(jsonString);
    final List<dynamic> cardsJson = parsedJson['cards'];

    Map<DigimonCard, int> cardAndCntMap = {};
    for (var cardJson in cardsJson) {
      DigimonCard card = DigimonCard.fromJson(cardJson);
      cardAndCntMap[card] = cardJson['cnt'];
    }

    return cardAndCntMap;
  }

  Future<dynamic> exportDeckToTTSFile(DeckBuild deck) async {
    try {
      var response = await dioClient.dio.post('$baseUrl/api/manager/deck',
          data: DeckRequestDto(deck).toJson());
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<FormatDto>?> getFormats(DateTime dateTime) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      var response =
          await dioClient.dio.get('$baseUrl/api/format?date=$formattedDate');
      if (response.statusCode == 200) {
        return FormatDto.fromJsonList(response.data);
      } else if (response.statusCode == 401) {
        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<PagedResponseDeckDto?> findDecks(
      DeckSearchParameter deckSearchParameter) async {
    try {
      var response = await dioClient.dio.get(
        '$baseUrl/api/deck',
        queryParameters: deckSearchParameter.toJson(),
      );
      if (response.statusCode == 200) {
        return PagedResponseDeckDto.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<DeckView>?> findAllMyDecks() async {
    try {
      var response = await dioClient.dio.get(
        '$baseUrl/api/deck/all',
      );
      if (response.statusCode == 200) {
        return DeckView.fromJsonList(response.data);
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  Future<bool> deleteDeck(int deckId) async {
    try {
      var response = await dioClient.dio.post('$baseUrl/api/deck/delete',
          queryParameters: {'deck-id': deckId});

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<FormatDeckCountDto?> getDeckCount() async {
    try {
      var response = await dioClient.dio.get('$baseUrl/api/format/deck-count');
      if (response.statusCode == 200) {
        return FormatDeckCountDto.fromJson(response.data);
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
