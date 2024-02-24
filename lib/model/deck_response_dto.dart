import 'dart:convert';

import 'card.dart';

class DeckResponseDto {
  int? authorId;
  String? authorName;
  int? deckId;
  String? deckName;
  Map<DigimonCard, int>? cardAndCntMap;

  DeckResponseDto({this.authorId, this.authorName, this.deckId, this.deckName,
      this.cardAndCntMap});

  factory DeckResponseDto.fromJson(Map<String, dynamic> json) {
    return DeckResponseDto(
      authorId: json['authorId'],
      authorName: json['authorName'],
      deckId: json['deckId'],
      deckName: json['deckName'],
      // JSON의 'cards' 배열을 직접 메서드에 전달
      cardAndCntMap: parseJsonToCardAndCntMap(json['cards'] as List<dynamic>),
    );
  }

  // static 메서드로 변경하고 인자 타입을 List<dynamic>으로 수정
  static Map<DigimonCard, int> parseJsonToCardAndCntMap(List<dynamic> cardsJson) {
    Map<DigimonCard, int> cardAndCntMap = {};
    for (var cardJson in cardsJson) {
      DigimonCard card = DigimonCard.fromJson(cardJson as Map<String, dynamic>);
      int cnt = cardJson['cnt'] as int; // 'cnt'를 int로 안전하게 캐스팅
      cardAndCntMap[card] = cnt;
    }
    return cardAndCntMap;
  }
}
