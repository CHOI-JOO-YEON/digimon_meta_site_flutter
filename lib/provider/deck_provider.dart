import 'package:flutter/material.dart';
import '../model/deck-build.dart';

class DeckProvider with ChangeNotifier {
  DeckBuild? _currentDeck;

  DeckBuild? get currentDeck => _currentDeck;

  void setCurrentDeck(DeckBuild? deck) {
    _currentDeck = deck;
    notifyListeners();
  }

  void clearCurrentDeck() {
    _currentDeck = null;
    notifyListeners();
  }
} 