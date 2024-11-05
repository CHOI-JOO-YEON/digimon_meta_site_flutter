import 'package:flutter/material.dart';

import '../model/card.dart';
import '../model/deck-build.dart';

class GameState extends ChangeNotifier {
  List<DigimonCard> mainDeck = [];
  List<DigimonCard> digitamaDeck = [];
  List<DigimonCard> hand = [];
  List<DigimonCard> securityStack = [];
  List<DigimonCard> trash = [];
  RaisingZone raisingZone = RaisingZone();
  List<FieldZone> fieldZones = [];
  int memory = 0;

  GameState(DeckBuild deckBuild) {
    // 메인 덱 초기화
    deckBuild.deckMap.forEach((card, count) {
      for (int i = 0; i < count; i++) {
        mainDeck.add(card);
      }
    });

    // 디지타마 덱 초기화
    deckBuild.tamaMap.forEach((card, count) {
      for (int i = 0; i < count; i++) {
        digitamaDeck.add(card);
      }
    });

    // 덱 섞기
    mainDeck.shuffle();
    digitamaDeck.shuffle();

    // 시큐리티 스택 설정 (5장)
    for (int i = 0; i < 5; i++) {
      securityStack.add(mainDeck.removeLast());
    }

    // 초기 패 설정 (5장)
    for (int i = 0; i < 5; i++) {
      hand.add(mainDeck.removeLast());
    }

    // 필드 존 초기화
    fieldZones.add(FieldZone());
  }

  void drawCard() {
    if (mainDeck.isNotEmpty) {
      hand.add(mainDeck.removeLast());
      notifyListeners();
    }
  }

  void updateMemory(int newMemory) {
    memory = newMemory.clamp(-10, 10);
    notifyListeners();
  }

  void removeCardFromOrigin(DigimonCard card) {
    if (hand.contains(card)) {
      hand.remove(card);
    } else if (raisingZone.digimonStack.contains(card)) {
      raisingZone.digimonStack.remove(card);
    }
    // 다른 영역에 대한 처리 추가 가능
    notifyListeners();
  }

  void moveCard(DigimonCard card, String from, String to) {
    // from과 to는 영역의 이름을 나타냄 ('hand', 'field', 'raising', 'trash' 등)
    switch (from) {
      case 'hand':
        hand.remove(card);
        break;
      case 'raising':
        raisingZone.digimonStack.remove(card);
        break;
      case 'field':
        // 필드에서 카드 제거 로직
        break;
      // 다른 영역에 대한 처리 추가
    }

    switch (to) {
      case 'hand':
        hand.add(card);
        break;
      case 'raising':
        raisingZone.digimonStack.add(card);
        break;
      case 'field':
        fieldZones[0].addDigimon(card);
        break;
      case 'trash':
        trash.add(card);
        break;
      // 다른 영역에 대한 처리 추가
    }

    notifyListeners();
  }
}

class RaisingZone extends ChangeNotifier {
  DigimonCard? eggCard;
  List<DigimonCard> digimonStack = [];

  void hatchEgg(List<DigimonCard> digitamaDeck) {
    if (digitamaDeck.isNotEmpty && eggCard == null) {
      eggCard = digitamaDeck.removeLast();
      notifyListeners();
    }
  }

  void evolveDigimon(DigimonCard digimon) {
    if (eggCard != null) {
      digimonStack.add(digimon);
      notifyListeners();
    }
  }

  DigimonCard? moveToField() {
    if (digimonStack.isNotEmpty) {
      DigimonCard? movingDigimon = digimonStack.last;
      eggCard = null;
      digimonStack.clear();
      notifyListeners();
      return movingDigimon;
    }
    return null;
  }

  void reorderDigimonStack(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    final card = digimonStack.removeAt(fromIndex);
    digimonStack.insert(toIndex, card);

    notifyListeners();
  }

  void addDigimonToIndex(DigimonCard card, int toIndex) {
    digimonStack.insert(toIndex, card);
    notifyListeners();
  }
}

class FieldZone extends ChangeNotifier {
  List<DigimonCard> digimonStack = []; // 디지몬 스택 (진화 포함)
  List<DigimonCard> tamerCards = [];
  List<DigimonCard> optionCards = [];

  void addDigimon(DigimonCard digimon) {
    digimonStack.add(digimon);
    notifyListeners();
  }

  void reorderDigimonStack(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    final card = digimonStack.removeAt(fromIndex);
    digimonStack.insert(toIndex, card);

    notifyListeners();
  }

  void addDigimonToIndex(DigimonCard card, int toIndex) {
    digimonStack.insert(toIndex, card);
    notifyListeners();
  }
}
