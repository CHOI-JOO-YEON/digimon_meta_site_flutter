import 'dart:html';

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
  DigimonCard? selectedCard;

  GameState(DeckBuild deckBuild) {
    for (int i = 0; i < 24; i++) {
      fieldZones.add(FieldZone());
    }
    deckBuild.deckMap.forEach((card, count) {
      for (int i = 0; i < count; i++) {
        mainDeck.add(card);
      }
    });

    deckBuild.tamaMap.forEach((card, count) {
      for (int i = 0; i < count; i++) {
        digitamaDeck.add(card);
      }
    });

    mainDeck.shuffle();
    digitamaDeck.shuffle();
    raisingZone.setDigitamaDeck(digitamaDeck);

    for (int i = 0; i < 5; i++) {
      securityStack.add(mainDeck.removeLast());
    }
    for (int i = 0; i < 5; i++) {
      hand.add(mainDeck.removeLast());
    }
  }

  void addFieldZone(int count) {
    for (int i = 0; i < count; i++) {
      fieldZones.add(FieldZone());
    }
    notifyListeners();
  }

  DigimonCard? getSelectedCard() {
    return selectedCard;
  }

  void updateSelectedCard(DigimonCard card) {
    selectedCard = card;
    notifyListeners();
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

  void reorderHand(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex == toIndex) return;

    final card = hand.removeAt(fromIndex);
    hand.insert(toIndex, card);

    notifyListeners();
  }

  void addCardToHandAt(DigimonCard card, int toIndex) {
    hand.insert(toIndex, card);
    notifyListeners();
  }

  void removeCardFromHandAt(int index) {
    hand.removeAt(index);
    notifyListeners();
  }
}

class RaisingZone extends ChangeNotifier {
  List<DigimonCard> _digitamaDeck = [];
  FieldZone fieldZone = FieldZone();

  void hatchEgg() {
    if (_digitamaDeck.isNotEmpty) {
      DigimonCard eggCard = _digitamaDeck.removeLast();
      fieldZone.addDigimon(eggCard);

      notifyListeners();
    }
  }

  void setDigitamaDeck(List<DigimonCard> digitamaDeck) {
    _digitamaDeck = digitamaDeck;
  }
}

class FieldZone extends ChangeNotifier {
  List<DigimonCard> stack = [];
  final Set<int> _rotatedCards = {};

  void addDigimon(DigimonCard digimon) {
    stack.add(digimon);
    notifyListeners();
  }

  void reorderStack(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    final card = stack.removeAt(fromIndex);
    stack.insert(toIndex, card);
    notifyListeners();
  }

  void addCardToStackAt(DigimonCard card, int index) {
    if (index == stack.length && _rotatedCards.contains(stack.length - 1)) {
      _rotatedCards.remove(stack.length - 1);
      _rotatedCards.add(index);
    } else {
      List<int> addIndexes = [];
      for (int i = index; i < stack.length; i++) {
        if (_rotatedCards.contains(i)) {
          _rotatedCards.remove(i);
          addIndexes.add(i + 1);
        }
      }
      for (var i in addIndexes) {
        _rotatedCards.add(i);
      }
    }

    stack.insert(index, card);
    notifyListeners();
  }

  void removeCardToStackAt(int index) {
    List<int> addIndexes = [];
    _rotatedCards.remove(index);

    for (int i = index + 1; i < stack.length; i++) {
      if (_rotatedCards.contains(i)) {
        _rotatedCards.remove(i);
        addIndexes.add(i - 1);
      }
    }
    for (var i in addIndexes) {
      _rotatedCards.add(i);
    }
    stack.removeAt(index);
    notifyListeners();
  }

  void rotateIndex(int index) {
    if (_rotatedCards.contains(index)) {
      _rotatedCards.remove(index);
    } else {
      _rotatedCards.add(index);
    }
    notifyListeners();
  }

  bool isRotate(int index) {
    return _rotatedCards.contains(index);
  }
}
