import 'dart:convert';

import 'package:digimon_meta_site_flutter/enums/special_limit_card_enum.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/limit_dto.dart';
import 'package:digimon_meta_site_flutter/provider/limit_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
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

  int? formatId;
  bool isPublic = false;

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

  void saveMapToLocalStorage() {
    Map<String, int> encodableMap = {
      ...deckMap.map((key, value) => MapEntry(key.cardId.toString(), value)),
      ...tamaMap.map((key, value) => MapEntry(key.cardId.toString(), value)),
    };
    if(encodableMap.isEmpty) {
      html.window.localStorage.remove('deck');
      return;
    }

    Map<String, dynamic> map = {
      'deckName': deckName,
      'deckMap': encodableMap,
    };

    String jsonString = jsonEncode(map);
    html.window.localStorage['deck'] = jsonString;
  }

  Deck.responseDto(DeckResponseDto deckResponseDto) {
    deckId = deckResponseDto.deckId;
    deckName = deckResponseDto.deckName!;
    author = deckResponseDto.authorName;
    authorId = deckResponseDto.authorId;
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

  void clear() {
    deckMap.clear();
    tamaMap.clear();
    deckCards.clear();
    tamaCards.clear();
    cardMap.clear();
    deckCount = 0;
    tamaCount = 0;
    html.window.localStorage.remove('deck');
  }

  addCard(DigimonCard card, BuildContext context) {
    LimitProvider limitProvider = Provider.of(context, listen: false);

    if (cardMap.containsKey(card.cardId)) {
      card = cardMap[card.cardId]!;
    } else {
      cardMap[card.cardId!] = card;
    }
    if (card.cardType == 'DIGITAMA') {
      if (tamaMap.containsKey(card)) {
        if (tamaMap[card]! < SpecialLimitCard.getLimitByCardNo(card.cardNo!) &&
            tamaMap[card]! <
                limitProvider.getCardAllowedQuantity(card.cardNo!)) {
          tamaMap[card] = tamaMap[card]! + 1;
          tamaCount++;
        }
      } else {
        if (limitProvider.getCardAllowedQuantity(card.cardNo!) > 0) {
          tamaMap[card] = 1;
          tamaCards.add(card);
          tamaCards.sort(digimonCardComparator);
          tamaCount++;
        }
      }
    } else {
      if (deckMap.containsKey(card)) {
        if (deckMap[card]! < SpecialLimitCard.getLimitByCardNo(card.cardNo!) &&
            deckMap[card]! <
                limitProvider.getCardAllowedQuantity(card.cardNo!)) {
          deckMap[card] = deckMap[card]! + 1;
          deckCount++;
        }
      } else {
        if (limitProvider.getCardAllowedQuantity(card.cardNo!) > 0) {
          deckMap[card] = 1;
          deckCards.add(card);
          deckCards.sort(digimonCardComparator);
          deckCount++;
        }
      }
    }
    saveMapToLocalStorage();
  }

  removeCard(DigimonCard card) {
    if (card.cardType == 'DIGITAMA') {
      if (tamaMap.containsKey(card)) {
        if (tamaMap[card] == 1) {
          tamaMap.remove(card);
          tamaCards.remove(card);
          tamaCards.sort(digimonCardComparator);
          tamaCount--;
          cardMap.remove(card.cardId);
        } else {
          tamaMap[card] = tamaMap[card]! - 1;
          tamaCount--;
        }
      }
    } else {
      if (deckMap.containsKey(card)) {
        if (deckMap[card] == 1) {
          deckMap.remove(card);
          deckCards.remove(card);
          deckCards.sort(digimonCardComparator);
          deckCount--;
          cardMap.remove(card.cardId);
        } else {
          deckMap[card] = deckMap[card]! - 1;
          deckCount--;
        }
      }
    }
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
