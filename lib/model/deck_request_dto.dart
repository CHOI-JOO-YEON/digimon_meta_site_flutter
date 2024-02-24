import 'deck.dart';

class DeckRequestDto{
  int? deckId;
  String? deckName;
  Map<int,int> cardAndCntMap ={};

  DeckRequestDto(Deck deck){
    deckId=deck.deckId;
    deckName=deck.deckName;

    for (var deckEntry in deck.deckMap.entries) {
        cardAndCntMap[deckEntry.key.cardId!]=deckEntry.value;
    }

    for (var deckEntry in deck.tamaMap.entries) {
      cardAndCntMap[deckEntry.key.cardId!]=deckEntry.value;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'deckId': deckId,
      'deckName': deckName,
    };

    final Map<String, int> convertedCardAndCntMap = {};
    cardAndCntMap.forEach((key, value) {
      convertedCardAndCntMap[key.toString()] = value;
    });
    data['cardAndCntMap'] = convertedCardAndCntMap;

    return data;
  }

}