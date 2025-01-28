import 'dart:convert';

import 'card.dart';

class DeckView {
  int? authorId;
  String? authorName;
  int? deckId;
  String? deckName;
  Map<DigimonCard, int>? cardAndCntMap;
  List<String>? colors = [];
  int? formatId;
  bool? isPublic;

  DeckView(
      {this.authorId,
      this.authorName,
      this.deckId,
      this.deckName,
      this.cardAndCntMap,
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

    return DeckView(
        authorId: json['authorId'],
        authorName: json['authorName'],
        deckId: json['deckId'],
        deckName: json['deckName'],
        colors: colors,
        cardAndCntMap: parseJsonToCardAndCntMap(json['cards'] as List<dynamic>),
        formatId: json['formatId'],
        isPublic: json['isPublic']);
  }

  static List<DeckView> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DeckView.fromJson(json)).toList();
  }

  static Map<DigimonCard, int> parseJsonToCardAndCntMap(
      List<dynamic> cardsJson) {
    Map<DigimonCard, int> cardAndCntMap = {};
    for (var cardJson in cardsJson) {
      DigimonCard card = DigimonCard.fromJson(cardJson as Map<String, dynamic>);
      int cnt = cardJson['cnt'] as int;
      cardAndCntMap[card] = cnt;
    }
    return cardAndCntMap;
  }

  @override
  String toString() {
    return 'DeckView{authorId: $authorId, authorName: $authorName, deckId: $deckId, deckName: $deckName, cardAndCntMap: $cardAndCntMap, colors: $colors, formatId: $formatId, isPublic: $isPublic}';
  }
}
