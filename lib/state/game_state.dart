import 'dart:math';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../model/card.dart';
import '../model/deck-build.dart';

class GameState extends ChangeNotifier {
  List<DigimonCard> mainDeck = [];
  List<DigimonCard> digitamaDeck = [];
  List<DigimonCard> hand = [];
  List<DigimonCard> shows = [];
  List<DigimonCard> securityStack = [];
  List<bool> securityFlipStatus = [];
  List<DigimonCard> trash = [];
  RaisingZone raisingZone = RaisingZone();
  Map<String, FieldZone> fieldZones = {};

  List<MoveCard> undoStack = [];
  List<MoveCard> redoStack = [];

  Map<String, bool> dragStatusMap = {};

  int memory = 0;
  DigimonCard? selectedCard;
  bool isShowTrash = false;

  GameState(DeckBuild deckBuild) {
    init(deckBuild);
  }

  void init(DeckBuild deckBuild) {
    mainDeck.clear();
    digitamaDeck.clear();
    hand.clear();
    shows.clear();
    securityStack.clear();
    securityFlipStatus.clear();
    trash.clear();
    raisingZone = RaisingZone();
    fieldZones.clear();

    undoStack.clear();
    redoStack.clear();

    dragStatusMap = {};
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

    for (int i = 0; i < min(5, mainDeck.length); i++) {
      securityStack.add(mainDeck.removeLast());
      securityFlipStatus.add(false);
    }
    for (int i = 0; i < min(5, mainDeck.length); i++) {
      hand.add(mainDeck.removeLast());
    }
    notifyListeners();
  }

  double showCardWidth(double cardWidth) {
    return cardWidth * 0.85;
  }

  void updateDragStatus(String key, bool status) {
    dragStatusMap[key] = status;
    notifyListeners();
  }

  bool getDragStatus(String key) {
    return dragStatusMap[key] ?? false;
  }

  void updateShowTrash(bool value) {
    isShowTrash = value;
    notifyListeners();
  }

  void addFieldZone(int count) {
    for (int i = fieldZones.length; i < count + fieldZones.length; i++) {
      String key = "field$i";
      fieldZones[key] = FieldZone(key: key);
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

  void addMoveStack(MoveCard move) {
    undoStack.add(move);
    redoStack.clear();
  }
  
  void drawCard() {
    if (mainDeck.isNotEmpty) {
      final fromIndex = mainDeck.length - 1;
      final toIndex = hand.length;
      hand.add(mainDeck.removeLast());
      addMoveStack(MoveCard.full(
              toId: "hand",
              fromId: "deck",
              toStartIndex: toIndex,
              fromStartIndex: fromIndex,
              fromEndIndex: fromIndex)
          .reverse());
      notifyListeners();
    }
  }

  void showCard() {
    if (mainDeck.isNotEmpty) {
      final fromIndex = mainDeck.length - 1;
      final toIndex = shows.length;
      shows.add(mainDeck.removeLast());
      addMoveStack(MoveCard.full(
              toId: "show",
              fromId: "deck",
              toStartIndex: toIndex,
              fromStartIndex: fromIndex,
              fromEndIndex: fromIndex)
          .reverse());
      notifyListeners();
    }
  }

  void addCardToDeckBottom(DigimonCard card, String from, int fromIndex) {
    mainDeck.insert(0, card);
    addMoveStack(MoveCard.full(
        toId: "deck",
        fromId: from,
        toStartIndex: 0,
        fromStartIndex: fromIndex,
        fromEndIndex: fromIndex));
    notifyListeners();
  }

  void addCardToDeckTop(DigimonCard card, String from, int fromIndex) {
    int toIndex = mainDeck.length;
    mainDeck.add(card);
    addMoveStack(MoveCard.full(
        toId: "deck",
        fromId: from,
        toStartIndex: toIndex,
        fromStartIndex: fromIndex,
        fromEndIndex: fromIndex));
    notifyListeners();
  }

  
  bool isShowDialog() {
    return shows.isNotEmpty;
  }

  List<DigimonCard> getCardsBySourceId(
      String fromId, int fromStartIndex, int fromEndIndex) {
    switch (fromId) {
      case "hand":
        return hand.sublist(fromStartIndex, fromEndIndex + 1);
      case "show":
        return shows.sublist(fromStartIndex, fromEndIndex + 1);
      case "deck":
        return mainDeck.sublist(fromStartIndex, fromEndIndex + 1);
      case "raising":
        return raisingZone.fieldZone.stack
            .sublist(fromStartIndex, fromEndIndex + 1);
      case "tama":
        return raisingZone._digitamaDeck
            .sublist(fromStartIndex, fromEndIndex + 1);
      case "trash":
        return trash.sublist(fromStartIndex, fromEndIndex + 1);
      case "security":
        return securityStack.sublist(fromStartIndex, fromEndIndex + 1);
    }

    if (fromId.startsWith("field")) {
      return fieldZones[fromId]!
          .stack
          .sublist(fromStartIndex, fromEndIndex + 1);
    }
    return [];
  }

  void moveCards(MoveCard move, List<DigimonCard> cards, bool isSaveStack) {
    List<DigimonCard> toCards = getCardListById(move.toId);
    List<DigimonCard> fromCards = getCardListById(move.fromId);
    if (move.toId == move.fromId && move.fromStartIndex > move.toStartIndex) {
      //remove
      fromCards.removeRange(move.fromStartIndex, move.fromEndIndex + 1);

      //add
      toCards.insertAll(move.toStartIndex, cards);

      if (move.toId == 'security' && move.fromId == 'security') {
        bool status = securityFlipStatus.removeAt(move.fromStartIndex);
        securityFlipStatus.insert(move.toStartIndex, status);
      } else if (move.fromId == 'security') {
        securityFlipStatus.removeRange(
            move.fromStartIndex, move.fromEndIndex + 1);
      } else if (move.toId == 'security') {
        for (int i = 0; i < move.fromEndIndex + 1 - move.fromStartIndex; i++) {
          securityFlipStatus.insert(move.toStartIndex + i, true);
        }
      }
    } else {
      //add
      toCards.insertAll(move.toStartIndex, cards);

      //remove
      fromCards.removeRange(move.fromStartIndex, move.fromEndIndex + 1);
      if (move.toId == 'security' && move.fromId == 'security') {
        bool status = securityFlipStatus[move.fromStartIndex];
        securityFlipStatus.insert(move.toStartIndex, status);
        securityFlipStatus.removeAt(move.fromStartIndex);
      } else if (move.toId == 'security') {
        for (int i = 0; i < move.fromEndIndex + 1 - move.fromStartIndex; i++) {
          securityFlipStatus.insert(move.toStartIndex + i, true);
        }
      } else if (move.fromId == 'security') {
        securityFlipStatus.removeRange(
            move.fromStartIndex, move.fromEndIndex + 1);
      }
    }
    if (isSaveStack) {
      undoStack.add(move.reverse());
      redoStack.clear();
    }
    notifyListeners();
  }

  void moveOrderedCards(MoveCard move, bool isSaveStack) {
    List<DigimonCard> toCards = getCardListById(move.toId);
    List<DigimonCard> fromCards = getCardListById(move.fromId);
    PriorityQueue<(int, DigimonCard)> pq =
        PriorityQueue<(int, DigimonCard)>((a, b) => a.$1.compareTo(b.$1));

    for (var m in move.moveSet) {
      pq.add((m.to, fromCards.removeAt(m.from)));
    }

    while (pq.isNotEmpty) {
      var m = pq.removeFirst();
      toCards.insert(m.$1, m.$2);
    }
    if (isSaveStack) {
      undoStack.add(move.reverse());
      redoStack.clear();
    }

    notifyListeners();
  }

  void undo() {
    if (undoStack.isEmpty) return;
    MoveCard move = undoStack.removeLast();
    if (move.moveSet.isNotEmpty) {
      moveOrderedCards(move, false);
    } else {
      List<DigimonCard> cards = getCardsBySourceId(
          move.fromId, move.fromStartIndex, move.fromEndIndex);
      moveCards(move, cards, false);
    }
    redoStack.add(move.reverse());
  }

  void redo() {
    if (redoStack.isEmpty) return;
    MoveCard move = redoStack.removeLast();
    if (move.moveSet.isNotEmpty) {
      moveOrderedCards(move, false);
    } else {
      List<DigimonCard> cards = getCardsBySourceId(
          move.fromId, move.fromStartIndex, move.fromEndIndex);
      moveCards(move, cards, false);
    }
    undoStack.add(move.reverse());
  }

  List<DigimonCard> getCardListById(String id) {
    switch (id) {
      case "hand":
        return hand;
      case "show":
        return shows;
      case "deck":
        return mainDeck;
      case "raising":
        return raisingZone.fieldZone.stack;
      case "trash":
        return trash;
      case "security":
        return securityStack;
      case "tama":
        return raisingZone._digitamaDeck;
    }
    if (id.startsWith("field")) {
      return fieldZones[id]!.stack;
    }
    return [];
  }

  void flipSecurity(int index) {
    securityFlipStatus[index] = !securityFlipStatus[index];
    notifyListeners();
  }

  void flipAllSecurity(bool status) {
    for (int i = 0; i < securityFlipStatus.length; i++) {
      securityFlipStatus[i] = status;
    }

    notifyListeners();
  }

  void shuffleSecurity() {
    securityStack.shuffle();
    securityFlipStatus =
        List.filled(securityStack.length, false, growable: true);

    notifyListeners();
  }

  void recoveryFromDeck() {
    if (mainDeck.isNotEmpty) {
      securityStack.add(mainDeck.removeLast());
      securityFlipStatus.add(false);
    }
    notifyListeners();
  }
}

class RaisingZone extends ChangeNotifier {
  List<DigimonCard> _digitamaDeck = [];
  FieldZone fieldZone = FieldZone(key: "raising");
  String key = "tama";

  int getTamaDeckLength() {
    return _digitamaDeck.length;
  }

  void hatchEgg(GameState gameState) {
    if (_digitamaDeck.isNotEmpty) {
      DigimonCard eggCard = _digitamaDeck.removeLast();
      fieldZone.addCardToStackAt(eggCard, fieldZone.stack.length,
          _digitamaDeck.length, key, 'raising', gameState);

      notifyListeners();
      gameState.notifyListeners();
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

  void addCardToStackAt(DigimonCard card, int toIndex, int fromIndex,
      String from, String to, GameState gameState) {
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
    gameState.addMoveStack(MoveCard.full(
            toId: to,
            fromId: from,
            toStartIndex: toIndex,
            fromStartIndex: fromIndex,
            fromEndIndex: fromIndex)
        .reverse());
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

class MoveCard {
  String toId = "";
  String fromId = "";

  int toStartIndex = 0;
  int fromStartIndex = 0;
  int fromEndIndex = 0;
  SplayTreeSet<MoveIndex> moveSet =
      SplayTreeSet<MoveIndex>((a, b) => b.from.compareTo(a.from));

  MoveCard({
    required this.fromId,
    required this.fromStartIndex,
    required this.fromEndIndex,
  });

  MoveCard.full(
      {required this.fromId,
      required this.fromStartIndex,
      required this.fromEndIndex,
      required this.toId,
      required this.toStartIndex});

  @override
  String toString() {
    return 'MoveCard{toId: $toId, fromId: $fromId, toStartIndex: $toStartIndex, fromStartIndex: $fromStartIndex, fromEndIndex: $fromEndIndex, moveSet: $moveSet}';
  }

  MoveCard reverse() {
    int size = fromEndIndex - fromStartIndex;
    var reverse = MoveCard(
        fromId: toId,
        fromStartIndex: toStartIndex,
        fromEndIndex: toStartIndex + size);
    reverse.toStartIndex = fromStartIndex;
    reverse.toId = fromId;
    for (var move in moveSet) {
      reverse.moveSet.add(MoveIndex(move.from, move.to));
    }

    return reverse;
  }
}

class MoveIndex {
  int to;
  int from;

  MoveIndex(this.to, this.from);

  @override
  String toString() {
    return 'MoveIndex{to: $to, from: $from}';
  }
}
