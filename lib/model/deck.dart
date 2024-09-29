import 'dart:convert';
import 'dart:math';

import 'package:digimon_meta_site_flutter/enums/special_limit_card_enum.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/limit_dto.dart';
import 'package:digimon_meta_site_flutter/provider/limit_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../service/card_overlay_service.dart';
import 'card.dart';

class Deck {
  int? deckId;
  Map<DigimonCard, int> deckMap = {};
  List<DigimonCard> deckCards = [];
  Map<DigimonCard, int> tamaMap = {};
  List<DigimonCard> tamaCards = [];
  Map<int, DigimonCard> cardMap = {};
  int deckCount = 0;
  int tamaCount = 0;
  String deckName = 'My Deck';
  Set<String> colors = {};
  String? author;
  int? authorId;
  LimitDto? limitDto = LimitProvider().getCurrentLimit();
  bool isSave=false;

  Map<String, int> cardNoCntMap = {};
  int? formatId;
  bool isPublic = false;
  bool isStrict = true;

  void clear() {
    deckMap.clear();
    tamaMap.clear();
    deckCards.clear();
    tamaCards.clear();
    cardMap.clear();
    cardNoCntMap.clear();
    deckCount = 0;
    tamaCount = 0;
    html.window.localStorage.remove('deck');
    isSave=false;
  }

  void init() {
    clear();
    deckId = null;
    deckName = "My Deck";
    author = null;
    authorId = null;
    formatId = null;
    isPublic = false;
    colors = {};
    html.window.localStorage.remove('deck');
  }

  void newCopy(){
    deckId = null;
    deckName = deckName+" Copy";
    isPublic = false;
    isSave=false;
  }

  void updateIsStrict(bool v){
    isStrict =v;
    saveMapToLocalStorage();
  }
  void saveMapToLocalStorage() {
    Map<String, int> encodableMap = {
      ...deckMap.map((key, value) => MapEntry(key.cardId.toString(), value)),
      ...tamaMap.map((key, value) => MapEntry(key.cardId.toString(), value)),
    };
    if (encodableMap.isEmpty) {
      html.window.localStorage.remove('deck');
      return;
    }

    Map<String, dynamic> map = {
      'deckName': deckName,
      'deckMap': encodableMap,
      'isStrict' : isStrict
    };

    String jsonString = jsonEncode(map);
    html.window.localStorage['deck'] = jsonString;
  }

  Deck.responseDto(DeckResponseDto deckResponseDto) {
    deckId = deckResponseDto.deckId;
    deckName = deckResponseDto.deckName!;
    author = deckResponseDto.authorName;
    authorId = deckResponseDto.authorId;
    formatId = deckResponseDto.formatId;
    if (deckResponseDto.cardAndCntMap != null) {
      for (var cardEntry in deckResponseDto.cardAndCntMap!.entries) {
        DigimonCard card = cardEntry.key;
        cardMap[card.cardId!] = card;
        if (card.cardType == 'DIGITAMA') {
          tamaMap[card] = cardEntry.value;
          tamaCards.add(card);

          tamaCount += cardEntry.value;
        } else {
          deckMap[card] = cardEntry.value;
          deckCards.add(card);

          deckCount += cardEntry.value;
        }
      }
    }
    tamaCards.sort(digimonCardComparator);
    deckCards.sort(digimonCardComparator);
    for (var color in  deckResponseDto.colors!) {
      colors.add(color);
    }

  }

  Deck.deck(Deck deck) {
    deckName = deck.deckName + ' Copy';
    formatId = deck.formatId;
    for (var tama in deck.tamaMap.entries) {
      cardMap[tama.key.cardId!] = tama.key;
      tamaMap[tama.key] = tama.value;
      tamaCards.add(tama.key);

      tamaCount += tama.value;
    }

    for (var card in deck.deckMap.entries) {
      cardMap[card.key.cardId!] = card.key;
      deckMap[card.key] = card.value;
      deckCards.add(card.key);

      deckCount += card.value;
    }
    tamaCards.sort(digimonCardComparator);
    deckCards.sort(digimonCardComparator);
    for (var color in  deck.colors) {
      colors.add(color);
    }
  }

  Deck();

  Set<String> getCardColorSet() {
    Set<String> colorSet = {};
    for (var card in cardMap.values) {
      if (card.color1 != null) {
        colorSet.add(card.color1!);
      }
      if (card.color2 != null) {
        colorSet.add(card.color2!);
      }
    }
    return colorSet;
  }

  List<String> getOrderedCardColorList() {
    Set<String> colorSet = getCardColorSet();
    List<String> colorList = colorSet.toList();

    colorList.sort((a, b) {
      int orderA = _colorOrder[a] ?? 999;
      int orderB = _colorOrder[b] ?? 999;
      return orderA.compareTo(orderB);
    });

    return colorList;
  }

  void import(DeckResponseDto? deckResponseDto) {
    if (deckResponseDto != null) {
      clear();
      if (deckResponseDto.cardAndCntMap != null) {
        for (var cardEntry in deckResponseDto.cardAndCntMap!.entries) {
          DigimonCard card = cardEntry.key;

          cardMap[card.cardId!] = card;
          if (card.cardType == 'DIGITAMA') {
            tamaMap[card] = cardEntry.value;
            tamaCards.add(card);

            tamaCount += cardEntry.value;
          } else {
            deckMap[card] = cardEntry.value;
            deckCards.add(card);

            deckCount += cardEntry.value;
          }
        }
      }
      tamaCards.sort(digimonCardComparator);
      deckCards.sort(digimonCardComparator);
      saveMapToLocalStorage();
    }
  }

  DateTime getLatestCardDate() {
    DateTime latestReleaseDate = DateTime.fromMillisecondsSinceEpoch(0);

    cardMap.forEach((key, card) {
      if (card.releaseDate != null &&
          card.releaseDate!.isAfter(latestReleaseDate)) {
        latestReleaseDate = card.releaseDate!;
      }
    });

    return latestReleaseDate;
  }

  void _add(DigimonCard card, int limit, Map<DigimonCard, int> map,
      List<DigimonCard> cards) {
    CardOverlayService().removeAllOverlays();
    isSave=false;
    if (map.containsKey(card)) {
      if (map[card]! < limit) {
        map[card] = map[card]! + 1;
        _incrementCount(card.cardType!);
        _incrementCardNoCount(card);
      }
    } else {
      if (limit > 0) {
        map[card] = 1;
        cards.add(card);
        cards.sort(digimonCardComparator);
        _incrementCount(card.cardType!);
        _incrementCardNoCount(card);
      }
    }
  }

  void _incrementCount(String cardType) {
    if (cardType == 'DIGITAMA') {
      tamaCount++;
    } else {
      deckCount++;
    }
  }
  void _incrementCardNoCount(DigimonCard card)
  {
    if(cardNoCntMap.containsKey(card.cardNo)) {
      cardNoCntMap[card.cardNo!]= cardNoCntMap[card.cardNo]!+1;
    } else{
      cardNoCntMap[card.cardNo!]=1;
    }
  }
  addCard(DigimonCard card, BuildContext context) {

    LimitProvider limitProvider = Provider.of(context, listen: false);
    int limit = isStrict
        ? min(limitProvider.getCardAllowedQuantity(card.cardNo!),
            SpecialLimitCard.getLimitByCardNo(card.cardNo!))
        : 100;

    if (cardMap.containsKey(card.cardId)) {
      card = cardMap[card.cardId]!;
    } else {
      cardMap[card.cardId!] = card;
    }
    if (isStrict) {
      int cnt = cardNoCntMap[card.cardNo] ?? 0;
      if (cnt >= limit) {
        return;
      }
    }
    card.cardType == 'DIGITAMA'
        ? _add(card, limit, tamaMap, tamaCards)
        : _add(card, limit, deckMap, deckCards);

    saveMapToLocalStorage();
  }

  void _remove(
      DigimonCard card, Map<DigimonCard, int> map, List<DigimonCard> cards) {
    isSave=false;
    if (!map.containsKey(card)) {
      return;
    }

    if (map[card] == 1) {
      map.remove(card);
      cards.remove(card);
      cards.sort(digimonCardComparator);
      cardMap.remove(card.cardId);
    } else {
      map[card] = map[card]! - 1;
    }
    _decrementCount(card.cardType!);
    _decrementCardNoCount(card);
  }

  void _decrementCount(String cardType) {
    if (cardType == 'DIGITAMA') {
      tamaCount--;
    } else {
      deckCount--;
    }
  }
  void _decrementCardNoCount(DigimonCard card)
  {
    if (!cardNoCntMap.containsKey(card.cardNo)) {
      return;
    }

    if (cardNoCntMap[card.cardNo] == 1) {
      cardNoCntMap.remove(card.cardNo);
    } else {
      cardNoCntMap[card.cardNo!] = cardNoCntMap[card.cardNo]! - 1;
    }
  }
  removeCard(DigimonCard card) {
    card.cardType == 'DIGITAMA'
        ? _remove(card, tamaMap, tamaCards)
        : _remove(card, deckMap, deckCards);
    saveMapToLocalStorage();
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
  static final Map<String, int> _cardTypeOrder = {
    'DIGIMON': 1,
    'TAMER': 2,
    'OPTION': 3
  };

  int digimonCardComparator(DigimonCard a, DigimonCard b) {
    // cardType 정렬
    if (a.cardType != b.cardType) {
      return _cardTypeOrder[a.cardType]!.compareTo(_cardTypeOrder[b.cardType]!);
    }

    // lv 오름차순
    if (a.lv != null && b.lv != null && a.lv != b.lv) {
      return a.lv!.compareTo(b.lv!);
    }

    // color1 정렬
    if (a.color1 != null && b.color1 != null && a.color1 != b.color1) {
      return _colorOrder[a.color1]!.compareTo(_colorOrder[b.color1]!);
    }

    if (a.playCost != null && b.playCost != null && a.playCost != b.playCost) {
      return a.playCost!.compareTo(b.playCost!);
    }

    // sortString 오름차순
    if (a.sortString != b.sortString) {
      return a.sortString!.compareTo(b.sortString!);
    }

    // isParallel
    if (a.isParallel != b.isParallel) {
      return a.isParallel! ? 1 : -1;
    }

    return 0;
  }

  void colorArrange(Set<String> set) {
    var removeSet = [];
    for (var o in colors) {
      if (!set.contains(o)) {
        removeSet.add(o);
      }
    }
    for (var o in removeSet) {
      colors.remove(o);
    }
  }
}
