import 'dart:convert';

import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'card.dart';

class DeckView {
  int? authorId;
  String? authorName;
  int? deckId;
  String? deckName;
  Map<int, int>? cardIdAndCntMap;
  List<String>? colors = [];
  int? formatId;
  bool? isPublic;

  DeckView(
      {this.authorId,
      this.authorName,
      this.deckId,
      this.deckName,
      this.cardIdAndCntMap,
      this.colors,
      this.formatId,
      this.isPublic}) {
    if (colors != null) {
      colors = _sortColorsByOrder(colors!);
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
    return colors.toList()
      ..sort((a, b) => _colorOrder[a]!.compareTo(_colorOrder[b]!));
  }

  factory DeckView.fromJson(Map<String, dynamic> json) {
    var colors;
    if (json['colors'] != null) {
      colors = List<String>.from(json['colors']);
    } else {
      colors = null;
    }

    Map<int, int>? cardMap;
    if (json['cards'] != null) {
      if (json['cards'] is List) {
        // Handle when cards is a list of objects
        cardMap = parseJsonToCardIdAndCntMap(json['cards'] as List<dynamic>);
      } else if (json['cards'] is Map) {
        // Handle when cards is a map
        cardMap = {};
        final cardsMap = json['cards'] as Map<String, dynamic>;
        cardsMap.forEach((key, value) {
          try {
            final cardId = int.parse(key);
            final cnt = value as int;
            cardMap![cardId] = cnt;
          } catch (e) {
          }
        });
      }
    }

    return DeckView(
        authorId: json['authorId'],
        authorName: json['authorName'],
        deckId: json['deckId'],
        deckName: json['deckName'],
        colors: colors,
        cardIdAndCntMap: cardMap,
        formatId: json['formatId'],
        isPublic: json['isPublic']);
  }

  static List<DeckView> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DeckView.fromJson(json)).toList();
  }

  static Map<int, int> parseJsonToCardIdAndCntMap(List<dynamic> cardsJson) {
    Map<int, int> cardIdAndCntMap = {};
    for (var cardJson in cardsJson) {
      int cardId = cardJson['cardId'] as int;
      int cnt = cardJson['cnt'] as int;
      cardIdAndCntMap[cardId] = cnt;
    }
    return cardIdAndCntMap;
  }

  Map<DigimonCard, int>? getCardAndCntMap() {
    if (cardIdAndCntMap == null) return null;
    
    Map<DigimonCard, int> result = {};
    CardDataService cardService = CardDataService();
    
    cardIdAndCntMap!.forEach((cardId, cnt) {
      DigimonCard? card = cardService.getCardById(cardId);
      if (card != null) {
        result[card] = cnt;
      }
    });
    
    return result;
  }

  @override
  String toString() {
    return 'DeckView{authorId: $authorId, authorName: $authorName, deckId: $deckId, deckName: $deckName, cardIdAndCntMap: $cardIdAndCntMap, colors: $colors, formatId: $formatId, isPublic: $isPublic}';
  }
}
