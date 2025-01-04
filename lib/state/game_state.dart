import 'package:flutter/material.dart';

import '../model/card.dart';
import '../model/deck-build.dart';

class GameState extends ChangeNotifier {
  List<DigimonCard> mainDeck = [];
  List<DigimonCard> digitamaDeck = [];
  List<DigimonCard> hand = [];
  List<DigimonCard> shows = [];
  List<DigimonCard> securityStack = [];
  List<DigimonCard> trash = [];
  RaisingZone raisingZone = RaisingZone();
  Map<String, FieldZone> fieldZones = {};
  List<MoveLog> undoStack = [];
  List<MoveLog> redoStack = [];

  int memory = 0;
  DigimonCard? selectedCard;

  GameState(DeckBuild deckBuild) {
    for (int i = 0; i < 16; i++) {
      String key = "field$i";
      fieldZones[key] = FieldZone(key: key);
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
    for (int i = fieldZones.length; i < count + fieldZones.length; i++) {
      String key = "field$i";
      fieldZones[key] = FieldZone(key: key);
    }
    notifyListeners();
  }

  void undo() {
    if (undoStack.isEmpty) return;
    MoveLog moveLog = undoStack.removeLast();
    print(moveLog);
    DigimonCard? card = getCardByLog(moveLog.to, moveLog.toIndex);
    if (card != null) {
      addCardByLog(moveLog.from, moveLog.fromIndex, card);
    }
    redoStack.add(MoveLog.reverse(moveLog));
    if (moveLog.size != null) {
      for (int i = 1; i < moveLog.size!; i++) {
        undo();
      }
    }
    notifyListeners();
  }

  void redo() {
    if (redoStack.isEmpty) return;
    MoveLog moveLog = redoStack.removeLast();
    DigimonCard? card = getCardByLog(moveLog.to, moveLog.toIndex);
    if (card != null) {
      addCardByLog(moveLog.from, moveLog.fromIndex, card);
    }
    undoStack.add(MoveLog.reverse(moveLog));
    if (moveLog.size != null) {
      for (int i = 1; i < moveLog.size!; i++) {
        undo();
      }
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

  void addMoveStack(MoveLog moveLog) {
    undoStack.add(moveLog);
    redoStack.clear();
  }

  void drawCard() {
    if (mainDeck.isNotEmpty) {
      final fromIndex = mainDeck.length - 1;
      final toIndex = hand.length;
      hand.add(mainDeck.removeLast());
      addMoveStack(MoveLog(
          to: "hand", from: "deck", toIndex: toIndex, fromIndex: fromIndex));
      notifyListeners();
    }
  }

  void showCard() {
    if (mainDeck.isNotEmpty) {
      final fromIndex = mainDeck.length - 1;
      final toIndex = shows.length;
      shows.add(mainDeck.removeLast());
      addMoveStack(MoveLog(
          to: "show", from: "deck", toIndex: toIndex, fromIndex: fromIndex));
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
    addMoveStack(MoveLog(
        to: "hand", from: "hand", toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void reorderShow(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex == toIndex) return;

    final card = shows.removeAt(fromIndex);
    shows.insert(toIndex, card);
    addMoveStack(MoveLog(
        to: "show", from: "show", toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void addCardToHandAt(
      DigimonCard card, int toIndex, String from, int fromIndex) {
    hand.insert(toIndex, card);
    addMoveStack(MoveLog(
        to: "hand", from: from, toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void addCardToShowsAt(
      DigimonCard card, int toIndex, String from, int fromIndex) {
    shows.insert(toIndex, card);
    addMoveStack(MoveLog(
        to: "show", from: from, toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void removeCardFromHandAt(int index) {
    hand.removeAt(index);
    notifyListeners();
  }

  void removeCardFromShowsAt(int index) {
    shows.removeAt(index);
    notifyListeners();
  }

  bool isShowDialog() {
    return shows.isNotEmpty;
  }

  DigimonCard? getCardByLog(String to, int toIndex) {
    switch (to) {
      case "hand":
        return hand.removeAt(toIndex);
      case "show":
        return shows.removeAt(toIndex);
      case "deck":
        return mainDeck.removeAt(toIndex);
      case "raising":
        return raisingZone.fieldZone.stack.removeAt(toIndex);
    }

    if (to.startsWith("field")) {
      return fieldZones[to]!.stack.removeAt(toIndex);
    }
    return null;
  }

  void addCardByLog(String from, int fromIndex, DigimonCard card) {
    switch (from) {
      case "hand":
        return hand.insert(fromIndex, card);
      case "show":
        return shows.insert(fromIndex, card);
      case "deck":
        return mainDeck.insert(fromIndex, card);
      case "raising":
        return raisingZone.fieldZone.stack.insert(fromIndex, card);
    }

    if (from.startsWith("field")) {
      return fieldZones[from]!.stack.insert(fromIndex, card);
    }
  }
}

class RaisingZone extends ChangeNotifier {
  List<DigimonCard> _digitamaDeck = [];
  FieldZone fieldZone = FieldZone(key: "raising");
  String key = "tama";

  void hatchEgg(GameState gameState) {
    if (_digitamaDeck.isNotEmpty) {
      DigimonCard eggCard = _digitamaDeck.removeLast();
      fieldZone.addCardToStackAt(eggCard, fieldZone.stack.length,
          _digitamaDeck.length, key, gameState);

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
  final String key;

  FieldZone({required this.key});

  void reorderStack(int fromIndex, int toIndex, GameState gameState) {
    if (fromIndex == toIndex) return;
    final card = stack.removeAt(fromIndex);
    stack.insert(toIndex, card);
    MoveLog moveLog =
        MoveLog(to: key, from: key, toIndex: toIndex, fromIndex: fromIndex);
    print(moveLog);
    gameState.addMoveStack(moveLog);

    notifyListeners();
  }

  void addCardToStackAt(DigimonCard card, int toIndex, int fromIndex,
      String from, GameState gameState) {
    if (toIndex == stack.length && _rotatedCards.contains(stack.length - 1)) {
      _rotatedCards.remove(stack.length - 1);
      _rotatedCards.add(toIndex);
    } else {
      List<int> addIndexes = [];
      for (int i = toIndex; i < stack.length; i++) {
        if (_rotatedCards.contains(i)) {
          _rotatedCards.remove(i);
          addIndexes.add(i + 1);
        }
      }
      for (var i in addIndexes) {
        _rotatedCards.add(i);
      }
    }

    stack.insert(toIndex, card);
    gameState.addMoveStack(
        MoveLog(to: key, from: from, toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void removeCardToStackAt(int index) {
    if (index == stack.length - 1 && _rotatedCards.contains(stack.length - 1)) {
      if (stack.length > 1) {
        _rotatedCards.remove(stack.length - 1);
        _rotatedCards.add(stack.length - 2);
      } else {
        _rotatedCards.clear();
      }
    } else {
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

class MoveLog {
  String to = "";
  String from = "";

  int toIndex = 0;
  int fromIndex = 0;
  int? size;

  MoveLog(
      {required this.to,
      required this.from,
      required this.toIndex,
      required this.fromIndex,
      this.size});

  MoveLog.reverse(MoveLog moveLog) {
    to = moveLog.from;
    toIndex = moveLog.fromIndex;
    from = moveLog.to;
    fromIndex = moveLog.toIndex;
    size = moveLog.size;
  }

  @override
  String toString() {
    return 'MoveLog{to: $to, from: $from, toIndex: $toIndex, fromIndex: $fromIndex, size: $size}';
  }
}
