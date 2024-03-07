import 'dart:convert';

import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';

import '../model/deck.dart';
import 'dart:html' as html;
class DeckService{
  DeckApi deckApi = DeckApi();

  Future<Deck?> save(Deck deck) async {
    DeckResponseDto? responseDto = await deckApi.postDeck(deck);
    if(responseDto!=null) {
      return Deck.responseDto(responseDto);
    }
    return null;
  }

  Future<DeckResponseDto?> import(Map<String,int> deck) async {
    DeckResponseDto? responseDto = await deckApi.importDeck(deck);
    if(responseDto!=null) {
      return responseDto;
    }
    return null;
  }

  Future exportToTTSFile(Deck deck) async {
    dynamic jsonData = await deckApi.exportDeckToTTSFile(deck);

    if(jsonData!=null) {
      String jsonString = jsonEncode(jsonData);

      // Blob 객체 생성
      final blob = html.Blob([jsonString]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement anchor = html.AnchorElement(href: url)
        ..setAttribute("download", '${deck.deckName}.json')
        ..click();
      html.Url.revokeObjectUrl(url);
    }


  }
}