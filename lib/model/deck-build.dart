import 'dart:convert';
import 'dart:math';

import 'package:digimon_meta_site_flutter/enums/special_limit_card_enum.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/limit_dto.dart';
import 'package:digimon_meta_site_flutter/provider/limit_provider.dart';
import 'package:digimon_meta_site_flutter/service/limit_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../service/card_overlay_service.dart';
import 'card.dart';

class DeckBuild {
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

  bool isSave = false;

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
    isSave = false;
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

  void newCopy() {
    deckId = null;
    deckName = "$deckName Copy";
    isPublic = false;
    isSave = false;
  }

  void updateIsStrict(bool v) {
    isStrict = v;
    saveMapToLocalStorage();
  }

  DeckBuild.deckView(DeckView deckView) {
    deckId = deckView.deckId;
    deckName = deckView.deckName!;
    author = deckView.authorName;
    authorId = deckView.authorId;
    formatId = deckView.formatId;
    isPublic = deckView.isPublic ?? false;

    if (deckView.cardAndCntMap != null) {
      for (var cardEntry in deckView.cardAndCntMap!.entries) {
        DigimonCard card = cardEntry.key;
        for (int i = 0; i < cardEntry.value; i++) {
          if (!isCanAdd(card)) {
            return;
          }
          _addCard(card);
        }
      }
      _postDeckChanged();
    }

    for (var color in deckView.colors!) {
      colors.add(color);
    }
  }

  DeckBuild.deckBuild(DeckBuild deck) {
    deckName = '${deck.deckName} Copy';
    formatId = deck.formatId;

    for (var tamaEntry in deck.tamaMap.entries) {
      DigimonCard card = tamaEntry.key;
      int cnt = tamaEntry.value;
      for (int i = 0; i < cnt; i++) {
        if (!isCanAdd(card)) {
          return;
        }
        _addCard(card);
      }
    }

    for (var cardEntry in deck.deckMap.entries) {
      DigimonCard card = cardEntry.key;
      int cnt = cardEntry.value;
      for (int i = 0; i < cnt; i++) {
        if (!isCanAdd(card)) {
          return;
        }
        _addCard(card);
      }
    }
    _postDeckChanged();
    for (var color in deck.colors) {
      colors.add(color);
    }
  }

  DeckBuild();

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

  void import(DeckView? deckView) {
    if (deckView != null) {
      clear();
      if (deckView.cardAndCntMap != null) {
        for (var cardEntry in deckView.cardAndCntMap!.entries) {
          DigimonCard card = cardEntry.key;
          for (int i = 0; i < cardEntry.value; i++) {
            if (!isCanAdd(card)) {
              return;
            }
            _addCard(card);
          }
        }
        _postDeckChanged();
      }
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

  void _add(
      DigimonCard card, Map<DigimonCard, int> map, List<DigimonCard> cards) {
    if (!map.containsKey(card)) {
      CardOverlayService().removeAllOverlays();
      map[card] = 1;
      cards.add(card);
      cards.sort(digimonCardComparator);
    } else {
      map[card] = map[card]! + 1;
    }

    _incrementCount(card.cardType!);
    _incrementCardNoCount(card);
  }

  void _incrementCount(String cardType) {
    if (cardType == 'DIGITAMA') {
      tamaCount++;
    } else {
      deckCount++;
    }
  }

  void _incrementCardNoCount(DigimonCard card) {
    if (cardNoCntMap.containsKey(card.cardNo)) {
      cardNoCntMap[card.cardNo!] = cardNoCntMap[card.cardNo]! + 1;
    } else {
      cardNoCntMap[card.cardNo!] = 1;
    }
  }

  bool isCanAdd(card) {
    int limit = LimitService().getCardLimit(card);
    int cnt = cardNoCntMap[card.cardNo] ?? 0;
    if (cnt >= limit) {
      return false;
    }
    return true;
  }

  addSingleCard(DigimonCard card) {
    if (!isCanAdd(card)) {
      return;
    }
    _addCard(card);
    _postDeckChanged();
  }

  void _addCard(DigimonCard card) {
    card = cardMap.putIfAbsent(card.cardId!, () => card);
    card.cardType == 'DIGITAMA'
        ? _add(card, tamaMap, tamaCards)
        : _add(card, deckMap, deckCards);
  }

  void _postDeckChanged() {
    isSave = false;
    saveMapToLocalStorage();
  }

  void _remove(
      DigimonCard card, Map<DigimonCard, int> map, List<DigimonCard> cards) {
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

  void _decrementCardNoCount(DigimonCard card) {
    if (!cardNoCntMap.containsKey(card.cardNo)) {
      return;
    }

    if (cardNoCntMap[card.cardNo] == 1) {
      cardNoCntMap.remove(card.cardNo);
    } else {
      cardNoCntMap[card.cardNo!] = cardNoCntMap[card.cardNo]! - 1;
    }
  }

  bool isCanRemove(DigimonCard card) {
    if ((cardNoCntMap[card.cardNo] ?? 0) < 1) {
      return false;
    }
    return true;
  }

  void removeSingleCard(DigimonCard card) {
    if (!isCanRemove(card)) {
      return;
    }
    _removeCard(card);
    _postDeckChanged();
  }

  void _removeCard(DigimonCard card) {
    card.cardType == 'DIGITAMA'
        ? _remove(card, tamaMap, tamaCards)
        : _remove(card, deckMap, deckCards);
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

  void deckSort() {
    tamaCards.sort(digimonCardComparator);
    deckCards.sort(digimonCardComparator);
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
      'isStrict': isStrict
    };
    String jsonString = jsonEncode(map);
    html.window.localStorage['deck'] = jsonString;
  }

  List<String> sortPriority = [
    'cardType',
    'lv',
    'color1',
    'color2',
    'playCost',
    'sortString',
    'isParallel',
    'dp',
    'cardName'
  ];
  Map<String, String> sortPriorityTextMap ={
    'cardType' : '카드 타입',
    'lv' : '레벨',
    'color1' : '색상1',
    'color2' : '색상2',
    'playCost' : '등장/사용 코스트',
    'sortString' : '정렬 문자열',
    'isParallel' : '패럴렐 우선',
    'dp' : 'DP',
    'cardName' : '카드 이름'
  };
  String getSortPriorityKor(String sortString){
    return sortPriorityTextMap[sortString]??'';
  }

  int digimonCardComparator(DigimonCard a, DigimonCard b) {
  for (var criterion in sortPriority) {
    int comparison = 0;
    switch (criterion) {
      case 'cardType':
        comparison = _cardTypeOrder[a.cardType]?.compareTo(_cardTypeOrder[b.cardType] ?? double.infinity) ??
            double.infinity.compareTo(_cardTypeOrder[b.cardType] ?? double.infinity);
        break;
      case 'lv':
        comparison = (a.lv ?? double.infinity).compareTo(b.lv ?? double.infinity);
        break;
      case 'color1':
        comparison = _colorOrder[a.color1]?.compareTo(_colorOrder[b.color1] ?? double.infinity) ??
            double.infinity.compareTo(_colorOrder[b.color1] ?? double.infinity);
        break;
      case 'color2':
        comparison = _colorOrder[a.color2]?.compareTo(_colorOrder[b.color2] ?? double.infinity) ??
            double.infinity.compareTo(_colorOrder[b.color2] ?? double.infinity);
        break;
      case 'playCost':
        comparison = (a.playCost ?? double.infinity).compareTo(b.playCost ?? double.infinity);
        break;
      case 'dp':
        comparison = (a.dp ?? double.infinity).compareTo(b.dp ?? double.infinity);
        break;
      case 'sortString':
        comparison = (a.sortString ?? '').compareTo(b.sortString ?? '');
        break;
      case 'cardName':
        comparison = (a.cardName ?? '').compareTo(b.cardName ?? '');
        break;
      case 'isParallel':
        comparison = (a.isParallel! ? -1 : 1).compareTo(b.isParallel! ? -1 : 1);
        break;
      default:
        break;
    }

    if (comparison != 0) {
      return comparison;
    }
  }
  return 0;
}


  void setSortPriority(List<String> newPriority) {
    sortPriority = newPriority;
  }

// int digimonCardComparator(DigimonCard a, DigimonCard b) {
//   if (a.cardType != b.cardType) {
//     return _cardTypeOrder[a.cardType]!.compareTo(_cardTypeOrder[b.cardType]!);
//   }
//
//   if (a.lv != null && b.lv != null && a.lv != b.lv) {
//     return a.lv!.compareTo(b.lv!);
//   }
//
//   if (a.color1 != null && b.color1 != null && a.color1 != b.color1) {
//     return _colorOrder[a.color1]!.compareTo(_colorOrder[b.color1]!);
//   }
//
//   if (a.playCost != null && b.playCost != null && a.playCost != b.playCost) {
//     return a.playCost!.compareTo(b.playCost!);
//   }
//
//   if (a.sortString != b.sortString) {
//     return a.sortString!.compareTo(b.sortString!);
//   }
//
//   if (a.isParallel != b.isParallel) {
//     return a.isParallel! ? 1 : -1;
//   }
//
//   return 0;
// }
}
