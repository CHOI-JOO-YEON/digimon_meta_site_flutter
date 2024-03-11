import 'dart:convert';

import 'card.dart';

class DeckResponseDto {
  int? authorId;
  String? authorName;
  int? deckId;
  String? deckName;
  Map<DigimonCard, int>? cardAndCntMap;
  List<String>? colors = [];

  DeckResponseDto({this.authorId, this.authorName, this.deckId, this.deckName,
      this.cardAndCntMap, this.colors,}){
    if(colors!=null) {
      this.colors = _sortColorsByOrder(colors!);
    }
  }
  static final Map<String, int> _colorOrder = {
    'RED': 1,
    'BLUE': 2,
    'YELLOW': 3,
    'GREEN': 4,
    'BLACK': 5,
    'PURPLE': 6,
    'WHITE': 7
  };
  List<String> _sortColorsByOrder(List<String> colors) {
    return colors.toList()..sort((a, b) => _colorOrder[a]!.compareTo(_colorOrder[b]!));
  }
  factory DeckResponseDto.fromJson(Map<String, dynamic> json) {

     var colors ;
     if(json['colors']!=null) {
       colors = List<String>.from(json['colors']);
     }else{
       colors=null;
     }

    return DeckResponseDto(
      authorId: json['authorId'],
      authorName: json['authorName'],
      deckId: json['deckId'],
      deckName: json['deckName'],
      colors: colors,
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
