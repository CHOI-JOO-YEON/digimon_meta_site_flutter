import 'dart:convert';
import 'dart:typed_data';

import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/provider/deck_sort_provider.dart';
import 'package:digimon_meta_site_flutter/service/limit_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../service/card_overlay_service.dart';
import 'card.dart';

class DeckBuild {
  String baseUrl = const String.fromEnvironment('SERVER_URL');
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

  bool isSave = false;
  DeckSortProvider? deckSortProvider;
  Map<String, int> cardNoCntMap = {};
  int? formatId;
  bool isPublic = true;
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
    isPublic = true;
    colors = {};
    html.window.localStorage.remove('deck');
  }

  void newCopy() {
    deckId = null;
    deckName = "$deckName Copy";
    isPublic = true;
    isSave = false;
  }

  void updateIsStrict(bool v) {
    isStrict = v;
    saveMapToLocalStorage();
  }

DeckBuild.deckView(DeckView deckView, BuildContext context) {
  deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
  deckSortProvider!.addListener(deckSort);
  deckId = deckView.deckId;
  deckName = deckView.deckName??'';
  author = deckView.authorName;
  authorId = deckView.authorId;
  formatId = deckView.formatId;
  isPublic = deckView.isPublic ?? false;

  // Get cards using the helper method
  Map<DigimonCard, int>? cardAndCntMap = deckView.getCardAndCntMap();
  if (cardAndCntMap != null) {
    for (var cardEntry in cardAndCntMap.entries) {
      DigimonCard card = cardEntry.key;
      for (int i = 0; i < cardEntry.value; i++) {
        _addCard(card);
      }
    }
    isSave = false;
  }

  for (var color in deckView.colors??[]) {
    colors.add(color);
  }
}

  DeckBuild.deckBuild(DeckBuild deck, BuildContext context) {
    deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
    deckSortProvider!.addListener(deckSort);
    deckName = '${deck.deckName} Copy';
    formatId = deck.formatId;

    for (var tamaEntry in deck.tamaMap.entries) {
      DigimonCard card = tamaEntry.key;
      int cnt = tamaEntry.value;
      for (int i = 0; i < cnt; i++) {
        String? result = canAddCard(card);
        if (result != null) {
          return;
        }
        _addCard(card);
      }
    }

    for (var cardEntry in deck.deckMap.entries) {
      DigimonCard card = cardEntry.key;
      int cnt = cardEntry.value;
      for (int i = 0; i < cnt; i++) {
        String? result = canAddCard(card);
        if (result != null) {
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

  DeckBuild(BuildContext context) {
    deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
    deckSortProvider!.addListener(deckSort);
  }

  DeckBuild.empty();

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
      if (deckView.cardIdAndCntMap != null) {
        for (var cardEntry in deckView.cardIdAndCntMap!.entries) {
          DigimonCard card = cardMap[cardEntry.key]!;
          for (int i = 0; i < cardEntry.value; i++) {
            String? result = canAddCard(card);
            if (result != null) {
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
      cards.sort(deckSortProvider!.digimonCardComparator);
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

  String? canAddCard(DigimonCard card) { 
    int limit = LimitService().getCardLimit(card);
    int cnt = cardNoCntMap[card.cardNo] ?? 0;
    
    if (cnt >= limit && isStrict) {
      return '넣을 수 있는 매수를 초과했습니다';
    }
    if (isStrict && !LimitService().isAllowedByLimitPair(card.cardNo!, cardNoCntMap.keys.toSet())) {
      return 'A/B 제한에 해당하는 카드입니다.';
    }
    
      return null;
  }

  String? addSingleCard(DigimonCard card) {
    String? result = canAddCard(card);
    if (result != null) {
      return result;
    }
    _addCard(card);
    _postDeckChanged();
    return null;
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
      cards.sort(deckSortProvider!.digimonCardComparator);
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
    deckCards.sort(deckSortProvider!.digimonCardComparator);
    tamaCards.sort(deckSortProvider!.digimonCardComparator);
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

  String getQrUrl() {
    String url = "$baseUrl/qr?";
    
    Map<int, int> combinedMap = {
      ...deckMap.map((key, value) => MapEntry(key.cardId!, value)),
      ...tamaMap.map((key, value) => MapEntry(key.cardId!, value)),
    };

    // 카드가 없으면 빈 문자열 반환
    if (combinedMap.isEmpty) {
      return "$url${Uri.encodeComponent("")}";
    }

    // 대량 카드 최적화된 압축 방식 (v3 형식)
    if (combinedMap.length > 30) {
      try {
        // 1. ID 정렬 및 델타 인코딩
        List<int> sortedIds = combinedMap.keys.toList()..sort();
        List<int> data = [];
        
        // 첫 번째 ID와 수량 저장
        int prevId = sortedIds[0];
        data.add(prevId >> 8); // 상위 바이트
        data.add(prevId & 0xFF); // 하위 바이트
        data.add(combinedMap[prevId]!);
        
        // 델타 인코딩 + 가변 길이 인코딩 (웹에서 사용 가능한 최적화)
        for (int i = 1; i < sortedIds.length; i++) {
          int currentId = sortedIds[i];
          int diff = currentId - prevId;
          
          // 작은 차이는 1바이트 인코딩
          if (diff < 128) {
            data.add(diff);
          } 
          // 중간 차이는 2바이트 인코딩
          else if (diff < 16384) {
            data.add(0x80 | (diff >> 8)); // 상위 바이트 + 마커
            data.add(diff & 0xFF); // 하위 바이트
          }
          // 큰 차이는 3바이트 인코딩 
          else {
            data.add(0xC0); // 마커
            data.add(diff >> 8); // 상위 바이트
            data.add(diff & 0xFF); // 하위 바이트
          }
          
          // 수량은 1바이트로 충분 (일반적으로 1-4장)
          data.add(combinedMap[currentId]!);
          
          prevId = currentId;
        }
        
        // 2. 바이트 배열로 변환
        Uint8List bytes = Uint8List(data.length);
        for (int i = 0; i < data.length; i++) {
          bytes[i] = data[i];
        }
        
        // 3. Base64Url 인코딩 (추가 압축 없이)
        String v3Encoded = "v3:${base64Url.encode(bytes)}";
        
        // 사이즈가 원래보다 작은지 확인
        String oldFormat = combinedMap.entries
            .map((entry) => "${entry.key}=${entry.value}")
            .join(",");
        
        // 더 작은 형식 사용
        String finalEncoded = v3Encoded.length < oldFormat.length ? v3Encoded : oldFormat;
        url += "deck=${Uri.encodeComponent(finalEncoded)}";
        return url;
      } catch (e) {
        print('Advanced compression error: $e');
        // 오류 시 기존 방식으로 폴백
      }
    }
    
    // 기존 방식 (적은 수의 카드) - v2 포맷
    List<int> sortedIds = combinedMap.keys.toList()..sort();
    List<int> data = [];
    
    // 첫 번째 값은 그대로 저장
    if (sortedIds.isNotEmpty) {
      data.add(sortedIds[0]);
      data.add(combinedMap[sortedIds[0]]!);
      
      // 이후 값들은 차이값으로 저장
      for (int i = 1; i < sortedIds.length; i++) {
        // 이전 ID와의 차이 저장
        data.add(sortedIds[i] - sortedIds[i-1]);
        data.add(combinedMap[sortedIds[i]]!);
      }
    }
    
    // 바이트로 변환하고 base64 인코딩
    Uint8List bytes = Uint8List(data.length * 2);
    ByteData byteData = ByteData.view(bytes.buffer);
    
    for (int i = 0; i < data.length; i++) {
      byteData.setUint16(i * 2, data[i], Endian.big);
    }
    
    String encoded = "v2:${base64Url.encode(bytes)}";
    
    // 기존 형식과 비교
    String oldFormatParam = combinedMap.entries
        .map((entry) => "${entry.key}=${entry.value}")
        .join(",");
    
    // 더 작은 형식 사용
    encoded = encoded.length < oldFormatParam.length ? encoded : oldFormatParam;
    
    url += "deck=${Uri.encodeComponent(encoded)}";
    return url;
  }

  @override
  String toString() {
    return 'DeckBuild{baseUrl: $baseUrl, deckId: $deckId, deckMap: $deckMap, deckCards: $deckCards, tamaMap: $tamaMap, tamaCards: $tamaCards, cardMap: $cardMap, deckCount: $deckCount, tamaCount: $tamaCount, deckName: $deckName, colors: $colors, author: $author, authorId: $authorId, isSave: $isSave, deckSortProvider: $deckSortProvider, cardNoCntMap: $cardNoCntMap, formatId: $formatId, isPublic: $isPublic, isStrict: $isStrict}';
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
