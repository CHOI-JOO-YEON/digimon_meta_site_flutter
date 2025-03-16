import 'dart:convert';
import 'package:digimon_meta_site_flutter/model/locale_card_data.dart';
import 'package:flutter/services.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';

class CardDataService {
  static final CardDataService _instance = CardDataService._internal();
  factory CardDataService() => _instance;
  CardDataService._internal();

  Map<int, DigimonCard> _allCards = {};
  Map<String, DigimonCard> _allCardsByCardNo = {};
  Set<String> _types = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // assets에서 cards.json 로드
      final String jsonString = await rootBundle.loadString('assets/data/cards.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      jsonList.forEach((json) {
        DigimonCard card = DigimonCard.fromJson(json);
        _allCards[card.cardId!] = card;
        _allCardsByCardNo[card.cardNo!] = card;
        _types.addAll(card.types ?? []);
      });

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  Set<String> searchTypes(String word) {
    Set<String> result = {};
    
    for (var type in _types) {
      if (type.contains(word)) {
        result.add(type);
      }
    }
    
    return result;
  }

  Set<String> getAllTypes() {
    return _types;
  }

  Future<CardResponseDto> searchCards(SearchParameter searchParameter) async {
    if (!_isInitialized) {
      await initialize();
    }

    List<DigimonCard> allCardsList = _allCards.values.toList();
    List<DigimonCard> filteredCards = _applyFilters(allCardsList, searchParameter);
    
    _applySorting(filteredCards, searchParameter);
    
    int totalElements = filteredCards.length;
    int pageSize = searchParameter.size ?? 20;
    int totalPages = (totalElements / pageSize).ceil();
    
    int page = searchParameter.page ?? 1;
    int startIndex = (page - 1) * pageSize;
    int endIndex = startIndex + pageSize;
    if (endIndex > totalElements) endIndex = totalElements;
    
    List<DigimonCard> pagedCards = [];
    if (startIndex < totalElements) {
      pagedCards = filteredCards.sublist(startIndex, endIndex);
    }
    
    return CardResponseDto(
      cards: pagedCards,
      totalPages: totalPages,
      totalElements: totalElements,
    );
  }

  List<DigimonCard> _applyFilters(List<DigimonCard> cards, SearchParameter params) {
    return cards.where((card) {
      bool matches = true;
      
      if (params.searchString != null && params.searchString!.isNotEmpty) {
        String searchLower = params.searchString!.toLowerCase();
        bool textMatches = false;
        
        for (LocaleCardData localeData in card.localeCardData ?? []) {
          if (localeData.name.toLowerCase().contains(searchLower) == true || localeData.effect?.toLowerCase().contains(searchLower) == true || localeData.sourceEffect?.toLowerCase().contains(searchLower) == true) {
            textMatches = true;
            break;
          }
        }
        
        bool cardNoMatches = card.cardNo?.toLowerCase().contains(searchLower) == true;
        
        matches = textMatches || cardNoMatches;
        if (!matches) return false;
      }
      
      if (params.noteId != null) {
        matches = card.noteId == params.noteId;
        if (!matches) return false;
      }
      
      if (params.cardTypes != null && params.cardTypes!.isNotEmpty) {
        matches = params.cardTypes!.contains(card.cardType);
        if (!matches) return false;
      }
      
      
      if (params.colors != null && params.colors!.isNotEmpty) {
        matches = params.colors!.contains(card.color1) || params.colors!.contains(card.color2) || params.colors!.contains(card.color3);
        if (!matches) return false;
      }
      
      if (params.lvs != null && params.lvs!.isNotEmpty) {
        matches = params.lvs!.contains(card.lv);
        if (!matches) return false;
      }
      
      if (params.rarities != null && params.rarities!.isNotEmpty) {
        matches = params.rarities!.contains(card.rarity);
        if (!matches) return false;
      }
      
      if (params.types.isNotEmpty) {
        bool typeMatches = false;
        
        if (params.typeOperation == 0) {
          typeMatches = true;
          for (var typeValue in params.types) {
            if (!(card.types?.contains(typeValue) ?? false)) {
              typeMatches = false;
              break;
            }
          }
        } else {
          for (var type in card.types ?? []) {
            if (params.types.contains(type)) {
              typeMatches = true;
              break;
            }
          }
        }
        
        matches = typeMatches;
        if (!matches) return false;
      }
      
      if(params.parallelOption == 1) {
        matches = card.isParallel == false;
      } else if(params.parallelOption == 2) {
        matches = card.isParallel == true;
      }
      if (!matches) return false;
      
      if (card.dp != null) {
        if (card.dp! < params.minDp! || card.dp! > params.maxDp!) {
          return false;
        }
      } else if (params.minDp! > 1000) {
        return false;
      }
      
      if (card.playCost != null) {
        if (card.playCost! < params.minPlayCost! || card.playCost! > params.maxPlayCost!) {
          return false;
        }
      } else if (params.minPlayCost! > 0) {
        return false;
      }
      
      if (card.digivolveCost1 != null) {
        if (card.digivolveCost1! < params.minDigivolutionCost! || 
            card.digivolveCost1! > params.maxDigivolutionCost!) {
          return false;
        }
      } else if (params.minDigivolutionCost! > 0) {
        return false;
      }
      
      if (!params.isEnglishCardInclude && card.isEn == true) {
        return false;
      }
          
      return matches;
    }).toList();
  }

  void _applySorting(List<DigimonCard> cards, SearchParameter params) {
    // 기본적으로 cardNo로 정렬
    cards.sort((a, b) => (a.sortString ?? '').compareTo(b.sortString ?? ''));
    
    // params.sortBy에 기반한 추가 정렬 로직 추가 가능
  }

  // ID로 카드를 얻기 위한 유틸리티 메서드
  DigimonCard? getCardById(int cardId) {
    return _allCards[cardId];
  }
  DigimonCard? getCardByCardNo(String cardNo) {
    return _allCardsByCardNo[cardNo];
  }
} 