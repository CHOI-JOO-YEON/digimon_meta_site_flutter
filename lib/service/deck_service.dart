import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';

import '../model/deck.dart';

class DeckService{
  DeckApi deckApi = DeckApi();

  Future<Deck?> save(Deck deck) async {
    DeckResponseDto? responseDto = await deckApi.postDeck(deck);
    if(responseDto!=null) {
      return Deck.responseDto(responseDto);
    }
    return null;
  }
}