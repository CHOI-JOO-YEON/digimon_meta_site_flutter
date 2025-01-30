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
  Map<String, bool> dragStatusMap = {};

  int memory = 0;
  DigimonCard? selectedCard;
  bool isShowTrash = false;

  void updateDragStatus(String key, bool status)
  {
    dragStatusMap[key] = status;
    notifyListeners();
  }
  
  bool getDragStatus(String key)
  {
    return dragStatusMap[key] ?? false;
  }
  
  void updateShowTrash(bool value) {
    isShowTrash = value;
    notifyListeners();
  }

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

  void reorderTrash(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex == toIndex) return;

    final card = trash.removeAt(fromIndex);
    trash.insert(toIndex, card);
    addMoveStack(MoveLog(
        to: "trash", from: "trash", toIndex: toIndex, fromIndex: fromIndex));
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

  void addCardToTrashAt(
      DigimonCard card, int toIndex, String from, int fromIndex) {
    trash.insert(toIndex, card);
    addMoveStack(MoveLog(
        to: "trash", from: from, toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void addCardToDeckBottom(DigimonCard card, String from, int fromIndex) {
    mainDeck.insert(0, card);
    addMoveStack(
        MoveLog(to: "deck", from: from, toIndex: 0, fromIndex: fromIndex));
    notifyListeners();
  }

  void addCardToDeckTop(DigimonCard card, String from, int fromIndex) {
    int toIndex = mainDeck.length;
    mainDeck.add(card);
    addMoveStack(MoveLog(
        to: "deck", from: from, toIndex: toIndex, fromIndex: fromIndex));
    notifyListeners();
  }

  void addCardToTrash(DigimonCard card, String from, int fromIndex) {
    trash.add(card);
    addMoveStack(MoveLog(
        to: "trash",
        from: from,
        toIndex: trash.length - 1,
        fromIndex: fromIndex));
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

  void removeCardFromTrashAt(int index) {
    trash.removeAt(index);
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
      case "trash":
        return trash.removeAt(toIndex);
    }

    if (to.startsWith("field")) {
      return fieldZones[to]!.stack.removeAt(toIndex);
    }
    return null;
  }

  void addCardByLog(String from, int fromIndex, DigimonCard card) {
    switch (from) {
      case "hand":
        fromIndex.clamp(0, hand.length - 1);
        return hand.insert(fromIndex, card);
      case "show":
        fromIndex.clamp(0, shows.length - 1);
        return shows.insert(fromIndex, card);
      case "deck":
        fromIndex.clamp(0, mainDeck.length - 1);
        return mainDeck.insert(fromIndex, card);
      case "raising":
        fromIndex.clamp(0, raisingZone.fieldZone.stack.length - 1);
        return raisingZone.fieldZone.stack.insert(fromIndex, card);
      case "trash":
        fromIndex.clamp(0, trash.length - 1);
        return trash.insert(fromIndex, card);
    }

    if (from.startsWith("field")) {
      fromIndex.clamp(0, fieldZones[from]!.stack.length - 1);
      return fieldZones[from]!.stack.insert(fromIndex, card);
    }
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

  void moveCards(MoveCard move, List<DigimonCard> cards) {
    List<DigimonCard> toCards = getCardListById(move.toId);
    List<DigimonCard> fromCards = getCardListById(move.fromId);
    if (move.toId == move.fromId && move.fromStartIndex > move.toStartIndex) {
      //remove
      fromCards.removeRange(move.fromStartIndex, move.fromEndIndex + 1);

      //add
      toCards.insertAll(move.toStartIndex, cards);
    } else {
      //add
      toCards.insertAll(move.toStartIndex, cards);

      //remove
      fromCards.removeRange(move.fromStartIndex, move.fromEndIndex + 1);
    }

    notifyListeners();
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
    }
    if (id.startsWith("field")) {
      return fieldZones[id]!.stack;
    }
    return [];
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

    // if (fromIndex < toIndex) {
    //   final card = stack[fromIndex];
    //   stack.insert
    // }
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

class MoveCard {
  String toId = "";
  String fromId = "";

  int toStartIndex = 0;
  int fromStartIndex = 0;
  int fromEndIndex = 0;

  MoveCard({required this.fromId,required this.fromStartIndex,required this.fromEndIndex});

  @override
  String toString() {
    return 'Move{toId: $toId, fromId: $fromId, toStartIndex: $toStartIndex, fromStartIndex: $fromStartIndex, fromEndIndex: $fromEndIndex}';
  }
}
