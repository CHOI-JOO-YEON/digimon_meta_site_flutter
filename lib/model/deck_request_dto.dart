import 'deck-build.dart';

class DeckRequestDto{
  int? deckId;
  String? deckName;
  List<String>? colors;
  int? formatId;
  bool? isPublic;
  Map<int,int> cardAndCntMap ={};

  DeckRequestDto(DeckBuild deck){
    deckId=deck.deckId;
    deckName=deck.deckName;
    colors= deck.colors.toList();
    formatId=deck.formatId;
    isPublic = deck.isPublic;

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
      'colors': colors,
      'isPublic': isPublic,
      'formatId':formatId,
    };

    final Map<String, int> convertedCardAndCntMap = {};
    cardAndCntMap.forEach((key, value) {
      convertedCardAndCntMap[key.toString()] = value;
    });
    data['cardAndCntMap'] = convertedCardAndCntMap;
    return data;
  }

}