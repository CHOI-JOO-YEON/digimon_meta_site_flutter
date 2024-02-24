import 'dart:convert';

import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck_request_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/util/dio.dart';
import 'package:dio/dio.dart';

import '../model/deck.dart';
import '../model/note.dart';

class DeckApi{

  String baseUrl = 'http://localhost:8080';
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

  Map<DigimonCard, int> parseJsonToCardAndCntMap(String jsonString) {
    final parsedJson = json.decode(jsonString);
    final List<dynamic> cardsJson = parsedJson['cards'];

    // 카드 정보를 DigimonCard 객체로 변환
    final List<DigimonCard> cards = cardsJson
        .map((cardJson) => DigimonCard.fromJson(cardJson))
        .toList();

    Map<DigimonCard, int> cardAndCntMap = {};
    for (var cardJson in cardsJson) {
      DigimonCard card = DigimonCard.fromJson(cardJson);
      cardAndCntMap[card] = cardJson['cnt'];
    }

    return cardAndCntMap;
  }

}