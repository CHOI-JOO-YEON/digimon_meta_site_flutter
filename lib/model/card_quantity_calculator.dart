import 'dart:math';

import 'card.dart';
import 'deck-view.dart';

class CardQuantityCalculator {
  Map<int, Map<int, int>> _formatCardQuantitiesById = {};
  Map<int, Map<String, int>> _formatCardQuantitiesByCardNo = {};
  Map<int, Set<int>> _checkedDeckIds = {};
  Map<int, int> maxQuantitiesById = {};
  Map<String, int> maxQuantitiesByCardNo = {};
  Map<int, DigimonCard> _cardMap = {};
  Map<String, DigimonCard> _cardNoMap = {};

  void addDeck(DeckView deck) {
    int formatId = deck.formatId!;
    int deckId = deck.deckId!;

    if (!_checkedDeckIds.containsKey(formatId)) {
      _checkedDeckIds[formatId] = Set<int>();
    }

    if (_checkedDeckIds[formatId]!.contains(deckId)) {
      return;
    } else {
      _addQuantitiesForDeck(deck);
      _checkedDeckIds[formatId]!.add(deckId);
    }

    _updateMaxQuantities();
  }

  void removeDeck(DeckView deck) {
    int formatId = deck.formatId!;
    int deckId = deck.deckId!;

    if (_checkedDeckIds[formatId]!.contains(deckId)) {
      _removeQuantitiesForDeck(deck);
      _checkedDeckIds[formatId]!.remove(deckId);
    }

    _updateMaxQuantities();
  }

  void _addQuantitiesForDeck(DeckView deck) {
    int formatId = deck.formatId!;

    if (!_formatCardQuantitiesById.containsKey(formatId)) {
      _formatCardQuantitiesById[formatId] = Map<int, int>();
    }
    if(!_formatCardQuantitiesByCardNo.containsKey(deck.formatId)) {
      _formatCardQuantitiesByCardNo[formatId] = Map<String, int>();
    }

    Map<int, int> cardQuantitiesById = _formatCardQuantitiesById[formatId]!;
    Map<String, int> cardQuantitiesByCardNo = _formatCardQuantitiesByCardNo[formatId]!;

    deck.cardIdAndCntMap!.forEach((cardId, count) {
      DigimonCard card = _cardMap[cardId]!;
      String cardNo = card.cardNo!;
      _cardMap[cardId] = card;
      _cardNoMap[card.cardNo!] = card;

      if (cardQuantitiesById.containsKey(cardId)) {
        cardQuantitiesById[cardId] = cardQuantitiesById[cardId]! + count;
      } else {
        cardQuantitiesById[cardId] = count;
      }

      if (cardQuantitiesByCardNo.containsKey(cardNo)) {
        cardQuantitiesByCardNo[cardNo] = cardQuantitiesByCardNo[cardNo]! + count;
      } else {
        cardQuantitiesByCardNo[cardNo] = count;
      }

    });
  }

  void _removeQuantitiesForDeck(DeckView deck) {
    int formatId = deck.formatId!;
    Map<int, int> cardQuantities = _formatCardQuantitiesById[formatId]!;
    Map<String, int> cardQuantitiesByCardNo = _formatCardQuantitiesByCardNo[formatId]!;
    deck.cardIdAndCntMap!.forEach((cardId, count) {
      String cardNo = _cardMap[cardId]!.cardNo!;
      if (cardQuantities.containsKey(cardId)) {
        cardQuantities[cardId] = cardQuantities[cardId]! - count;
        if (cardQuantities[cardId] == 0) {
          cardQuantities.remove(cardId);
        }
      }

      if (cardQuantitiesByCardNo.containsKey(cardNo)) {
        cardQuantitiesByCardNo[cardNo] = cardQuantitiesByCardNo[cardNo]! - count;
        if (cardQuantitiesByCardNo[cardNo] == 0) {
          cardQuantitiesByCardNo.remove(cardNo);
        }
      }
    });
  }

  void _updateMaxQuantities() {
    maxQuantitiesById.clear();
    maxQuantitiesByCardNo.clear();

    _formatCardQuantitiesById.forEach((formatId, cardQuantities) {
      cardQuantities.forEach((cardId, count) {
        if (maxQuantitiesById.containsKey(cardId)) {
          maxQuantitiesById[cardId] = max(maxQuantitiesById[cardId]!, count);
        } else {
          maxQuantitiesById[cardId] = count;
        }
      });
    });

    _formatCardQuantitiesByCardNo.forEach((formatId, cardQuantities) {
      cardQuantities.forEach((cardNo, count) {
        if (maxQuantitiesByCardNo.containsKey(cardNo)) {
          maxQuantitiesByCardNo[cardNo] = max(maxQuantitiesByCardNo[cardNo]!, count);
        } else {
          maxQuantitiesByCardNo[cardNo] = count;
        }
      });
    });
  }


  DigimonCard? getCardByCardNo(String cardNo) {
    return _cardNoMap[cardNo];
  }

  DigimonCard? getCardById(int id) {
    return _cardMap[id];
  }
}
