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

    fieldZones.add(FieldZone());
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
    stack.insert(index, card);
    notifyListeners();
  }

  void removeCardToStackAt(int index) {
    stack.removeAt(index);
    notifyListeners();
  }
}
