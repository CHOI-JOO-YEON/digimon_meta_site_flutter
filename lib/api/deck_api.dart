import 'dart:convert';

import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/deck_request_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';

import '../model/deck.dart';

class DeckApi{

  // String baseUrl = 'http://localhost:8080';
  String baseUrl = const String.fromEnvironment('SERVER_URL');
  DioClient dioClient = DioClient();

  Future<DeckResponseDto?> postDeck(Deck deck) async {
    try {
      var response = await dioClient.dio.post('$baseUrl/api/deck',data: DeckRequestDto(deck).toJson());
      if (response.statusCode == 200) {

         return DeckResponseDto.fromJson(response.data);

      } else if(response.statusCode==401) {
        return null;
      }
    } catch (e) {
      // throw Exception('Error occurred while fetching cards');
    }

  }
  Future<DeckResponseDto?> importDeck(Map<String,int> deckCode) async {
    try {
      var response = await dioClient.dio.post('$baseUrl/api/deck/import',data: {
        'deck' : deckCode
      });
      if (response.statusCode == 200) {

        return DeckResponseDto.fromJson(response.data);

      } else if(response.statusCode==401) {
        return null;
      }
    } catch (e) {
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

  Future<dynamic> exportDeckToTTSFile(Deck deck) async {
    try {
      var response = await dioClient.dio.post('$baseUrl/api/manager/deck',data: DeckRequestDto(deck).toJson());
      if (response.statusCode == 200) {
          return response.data;
      } else if(response.statusCode==401) {
      }
    } catch (e) {
      // throw Exception('Error occurred while fetching cards');
    }

  }
}