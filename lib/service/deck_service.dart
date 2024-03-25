import 'dart:convert';

import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';

import '../model/deck.dart';
import 'dart:html' as html;

import '../model/format.dart';
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

  Future<Map<int,FormatDto>> getFormats(Deck deck) async {
     List<FormatDto>? formats = await DeckApi().getFormats(deck.getLatestCardDate());
     Map<int,FormatDto> map = {};
     if(formats!=null){
       for (var format in formats) {
        map[format.formatId]=format;
      }
    }

    return map;
  }

  Future<List<FormatDto>> getAllFormat() async {
    List<FormatDto>? formats = await DeckApi().getFormats(DateTime(0));
    if(formats!=null) {
      return formats;
    }
    return [];
  }

  Future<PagedResponseDeckDto?> getDeck(DeckSearchParameter deckSearchParameter) async {
    PagedResponseDeckDto? decks = await DeckApi().findDecks(deckSearchParameter);

    return decks;
  }

  Future<bool> deleteDeck(int deckId) async {
    return await DeckApi().deleteDeck(deckId);
  }

}