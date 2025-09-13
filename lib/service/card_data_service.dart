import 'dart:convert';
import 'package:digimon_meta_site_flutter/model/locale_card_data.dart';
import 'package:flutter/services.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:web/web.dart';

class CardDataService {
  static final CardDataService _instance = CardDataService._internal();
  factory CardDataService() => _instance;
  CardDataService._internal();

  Map<int, DigimonCard> _allCards = {};
  Map<String, DigimonCard> _allCardsByCardNo = {};
  Set<String> _types = {};
  Set<String> _forms = {};
  Set<String> _attributes = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // assets에서 cards.json 로드
      final String jsonString = await rootBundle.loadString('assets/data/cards.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // 임시로 패럴렐 카드를 보관할 맵
      Map<String, DigimonCard> parallelCards = {};
      
      jsonList.forEach((json) {
        DigimonCard card = DigimonCard.fromJson(json);
        _allCards[card.cardId!] = card;
        
        // 비패럴렐 카드는 바로 맵에 추가
        if (!(card.isParallel ?? false)) {
          _allCardsByCardNo[card.cardNo!] = card;
        } else {
          // 패럴렐 카드는 임시 맵에 저장
          parallelCards[card.cardNo!] = card;
        }
        
        _types.addAll(card.types ?? []);
        
        if (card.form != null && card.form!.isNotEmpty) {
          _forms.add(card.form!);
        }
        
        if (card.attribute != null && card.attribute!.isNotEmpty) {
          _attributes.add(card.attribute!);
        }
      });
      
      // 비패럴렐 카드가 없는 경우에만 패럴렐 카드 추가
      parallelCards.forEach((cardNo, card) {
        if (!_allCardsByCardNo.containsKey(cardNo)) {
          _allCardsByCardNo[cardNo] = card;
        }
      });

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  void _initializeSync() {
    // 비동기 초기화가 완료되지 않은 경우, 동기적으로 초기화 진행
    if (!_isInitialized) {
      _isInitialized = true;
      // 비어있는 상태로 초기화하고 나중에 비동기로 로드될 것임
      _allCards = {};
      _allCardsByCardNo = {};
      _types = {};
      _forms = {};
      _attributes = {};
      // 비동기 초기화 시작
      initialize();
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
  
  Set<String> searchForms(String word) {
    Set<String> result = {};
    if (word.isEmpty) {
      return _forms; 
    }
    
    String searchWord = word.toLowerCase().trim();
    
    
    for (var form in _forms) {
      String korForm = getKorFormName(form);
      if (korForm.contains('/')) {
        List<String> parts = korForm.split('/');
        if (parts[0].trim().toLowerCase().contains(searchWord)) {
            result.add(form);
            break;
          }
      }
      else{
        if (korForm.toLowerCase().contains(searchWord)) {
          result.add(form);
          continue;
        }
      }
    }
    
    return result;
  }
  
  Set<String> searchAttributes(String word) {
    Set<String> result = {};
    
    for (var attribute in _attributes) {
      if (attribute.contains(word)) {
        result.add(attribute);
      }
    }
    
    return result;
  }

  Set<String> getAllTypes() {
    return _types;
  }
  
  Set<String> getAllForms() {
    return _forms;
  }
  
  Set<String> getAllAttributes() {
    return _attributes;
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
      
      // Handle general search string (existing functionality for backward compatibility)
      if (params.searchString != null && params.searchString!.isNotEmpty) {
        String searchString = params.searchString!;
        bool textMatches = false;
        bool isRegex = false;
        RegExp? regex;
        
        // Check if search string starts with @ for regex
        if (searchString.startsWith('@')) {
          searchString = searchString.substring(1); // Remove @ prefix
          try {
            regex = RegExp(searchString, caseSensitive: false);
            isRegex = true;
          } catch (e) {
            // If invalid regex, fall back to normal search
            searchString = searchString.toLowerCase();
          }
        } else {
          searchString = searchString.toLowerCase();
        }
        
        for (LocaleCardData localeData in card.localeCardData ?? []) {
          bool matches = false;
          if (isRegex) {
            matches = (localeData.name != null && regex!.hasMatch(localeData.name!)) ||
                    (localeData.effect != null && regex.hasMatch(localeData.effect!)) ||
                    (localeData.sourceEffect != null && regex.hasMatch(localeData.sourceEffect!));
          } else {
            matches = (localeData.name?.toLowerCase().contains(searchString) == true) ||
                    (localeData.effect?.toLowerCase().contains(searchString) == true) ||
                    (localeData.sourceEffect?.toLowerCase().contains(searchString) == true);
          }
          
          if (matches) {
            textMatches = true;
            break;
          }
        }
        
        bool cardNoMatches = false;
        if (isRegex) {
          cardNoMatches = card.cardNo != null && regex!.hasMatch(card.cardNo!);
        } else {
          cardNoMatches = card.cardNo?.toLowerCase().contains(searchString) == true;
        }
        
        matches = textMatches || cardNoMatches;
        if (!matches) return false;
      }
      
      // Handle detailed search conditions (new functionality)
      List<bool Function()> detailedSearchConditions = [];
      
      // Card name search
      if (params.cardNameSearch != null && params.cardNameSearch!.isNotEmpty) {
        detailedSearchConditions.add(() {
          String searchString = params.cardNameSearch!;
          bool isRegex = false;
          RegExp? regex;
          
          // Check if search string starts with @ for regex
          if (searchString.startsWith('@')) {
            searchString = searchString.substring(1); // Remove @ prefix
            try {
              regex = RegExp(searchString, caseSensitive: false);
              isRegex = true;
            } catch (e) {
              searchString = searchString.toLowerCase();
              isRegex = false;
            }
          } else {
            searchString = searchString.toLowerCase();
          }
          
          for (LocaleCardData localeData in card.localeCardData ?? []) {
            if (isRegex) {
              if (localeData.name != null && regex!.hasMatch(localeData.name!)) return true;
            } else {
              if (localeData.name?.toLowerCase().contains(searchString) == true) return true;
            }
          }
          return false;
        });
      }
      
      // Card number search
      if (params.cardNoSearch != null && params.cardNoSearch!.isNotEmpty) {
        detailedSearchConditions.add(() {
          String searchString = params.cardNoSearch!;
          bool isRegex = false;
          
          // Check if search string starts with @ for regex
          if (searchString.startsWith('@')) {
            searchString = searchString.substring(1); // Remove @ prefix
            try {
              RegExp regex = RegExp(searchString, caseSensitive: false);
              return card.cardNo != null && regex.hasMatch(card.cardNo!);
            } catch (e) {
              searchString = searchString.toLowerCase();
              return card.cardNo?.toLowerCase().contains(searchString) == true;
            }
          } else {
            searchString = searchString.toLowerCase();
            return card.cardNo?.toLowerCase().contains(searchString) == true;
          }
        });
      }
      
      // Effect search
      if (params.effectSearch != null && params.effectSearch!.isNotEmpty) {
        detailedSearchConditions.add(() {
          String searchString = params.effectSearch!;
          bool isRegex = false;
          RegExp? regex;
          
          // Check if search string starts with @ for regex
          if (searchString.startsWith('@')) {
            searchString = searchString.substring(1); // Remove @ prefix
            try {
              regex = RegExp(searchString, caseSensitive: false);
              isRegex = true;
            } catch (e) {
              searchString = searchString.toLowerCase();
              isRegex = false;
            }
          } else {
            searchString = searchString.toLowerCase();
          }
          
          for (LocaleCardData localeData in card.localeCardData ?? []) {
            if (localeData.effect != null) {
              if (isRegex) {
                if (regex!.hasMatch(localeData.effect!)) return true;
              } else {
                if (localeData.effect!.toLowerCase().contains(searchString)) return true;
              }
            }
          }
          return false;
        });
      }
      
      // Source effect search
      if (params.sourceEffectSearch != null && params.sourceEffectSearch!.isNotEmpty) {
        detailedSearchConditions.add(() {
          String searchString = params.sourceEffectSearch!;
          bool isRegex = false;
          RegExp? regex;
          
          // Check if search string starts with @ for regex
          if (searchString.startsWith('@')) {
            searchString = searchString.substring(1); // Remove @ prefix
            try {
              regex = RegExp(searchString, caseSensitive: false);
              isRegex = true;
            } catch (e) {
              searchString = searchString.toLowerCase();
              isRegex = false;
            }
          } else {
            searchString = searchString.toLowerCase();
          }
          
          for (LocaleCardData localeData in card.localeCardData ?? []) {
            if (localeData.sourceEffect != null) {
              if (isRegex) {
                if (regex!.hasMatch(localeData.sourceEffect!)) return true;
              } else {
                if (localeData.sourceEffect!.toLowerCase().contains(searchString)) return true;
              }
            }
          }
          return false;
        });
      }
      
      // Apply detailed search conditions with AND operation
      if (detailedSearchConditions.isNotEmpty) {
        for (var condition in detailedSearchConditions) {
          if (!condition()) {
            return false;
          }
        }
      }
      
      if (params.noteIds.isNotEmpty) {
        matches = params.noteIds.contains(card.noteId);
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
      
      if (params.forms.isNotEmpty) {
        bool formMatches = false;
        
        // "APPMON" 특수 처리: APPMON이 forms에 포함되어 있으면
        // STND, SUP, ULT, GOD 형태의 카드도 모두 매치되어야 함
        if (params.forms.contains("APPMON")) {
          formMatches = card.form != null && 
                      (params.forms.contains(card.form) || 
                       card.form == "STND" || 
                       card.form == "SUP" || 
                       card.form == "ULT" || 
                       card.form == "GOD");
        }
        // 일반적인 필터링 로직
        else if (params.formOperation == 0) {
          formMatches = card.form != null && params.forms.contains(card.form);
        } else {
          formMatches = card.form != null && params.forms.contains(card.form);
        }
        
        matches = formMatches;
        if (!matches) return false;
      }
      
      // Add filtering for attributes
      if (params.attributes.isNotEmpty) {
        bool attributeMatches = false;
        
        if (params.attributeOperation == 0) {
          // AND operation: The card attribute must match all selected attributes
          // Note: Since a card can only have one attribute, this will only match if exactly one attribute is selected
          // or if the same attribute is selected multiple times
          attributeMatches = card.attribute != null && params.attributes.contains(card.attribute);
        } else {
          // OR operation: The card attribute must match any of the selected attributes
          attributeMatches = card.attribute != null && params.attributes.contains(card.attribute);
        }
        
        matches = attributeMatches;
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
      
      // 발매일 필터링 추가
      if (params.minReleaseDate != null && card.releaseDate != null) {
        if (card.releaseDate!.isBefore(params.minReleaseDate!)) {
          return false;
        }
      }
      
      if (params.maxReleaseDate != null && card.releaseDate != null) {
        if (card.releaseDate!.isAfter(params.maxReleaseDate!)) {
          return false;
        }
      }
          
      return matches;
    }).toList();
  }

  void _applySorting(List<DigimonCard> cards, SearchParameter params) {
    if (params.isLatestReleaseFirst) {
          // 1차: 발매일이 오늘 이전이거나 오늘인 카드들을 최신 우선으로
    // 2차: sortString으로 정렬
      cards.sort((a, b) {
        DateTime today = DateTime.now();
        DateTime todayOnly = DateTime(today.year, today.month, today.day);
        
              // 발매일이 오늘 이전이거나 오늘인지 확인
      bool aIsReleasedBefore = a.releaseDate != null && !a.releaseDate!.isAfter(todayOnly);
      bool bIsReleasedBefore = b.releaseDate != null && !b.releaseDate!.isAfter(todayOnly);
        
        // 둘 다 오늘 이전이거나 오늘 발매된 카드라면 최신 발매일 우선
        if (aIsReleasedBefore && bIsReleasedBefore) {
          int releaseDateComparison = b.releaseDate!.compareTo(a.releaseDate!);
          if (releaseDateComparison != 0) {
            return releaseDateComparison; // 최신 발매일 먼저
          }
        }
        
        // 둘 다 오늘 이후 발매 예정 카드라면 sortString으로
        if (!aIsReleasedBefore && !bIsReleasedBefore) {
          return (a.sortString ?? '').compareTo(b.sortString ?? '');
        }
        
        // 하나는 오늘 이전/오늘, 하나는 아니라면 오늘 이전/오늘 카드가 먼저
        if (aIsReleasedBefore && !bIsReleasedBefore) {
          return -1; // a(오늘 이전/오늘 카드)가 먼저
        } else if (!aIsReleasedBefore && bIsReleasedBefore) {
          return 1; // b(오늘 이전/오늘 카드)가 먼저
        }
        
        // 최종적으로 sortString으로 정렬
        return (a.sortString ?? '').compareTo(b.sortString ?? '');
      });
    } else {
      // 기본적으로 sortString으로 정렬
      cards.sort((a, b) => (a.sortString ?? '').compareTo(b.sortString ?? ''));
    }
  }

  // ID로 카드를 얻기 위한 유틸리티 메서드
  DigimonCard? getCardById(int cardId) {
    if (!_isInitialized) {
      initialize();
    }
    
    return _allCards[cardId];
  }
  DigimonCard? getCardByCardNo(String cardNo) {
    if (!_isInitialized) {
      _initializeSync();
    }
    return _allCardsByCardNo[cardNo];
  }
  
  // 패럴렐 카드의 번호를 받아 같은 번호의 비패럴렐 카드를 반환하는 메서드
  DigimonCard? getNonParallelCardByCardNo(String cardNo) {
    if (!_isInitialized) {
      return null;
    }
    
    // _allCardsByCardNo에는 이미 가능한 비패럴렐 카드가 저장되어 있음
    return _allCardsByCardNo[cardNo];
  }

  // 영문 form 이름을 한글로 변환하는 메서드
  String getKorFormName(String englishForm) {
    // DigimonCard.getKorForm 메서드와 동일한 로직 사용
    String korForm;
    switch (englishForm) {
      case 'IN_TRAINING':
        korForm = '유년기';
        break;
      case 'ROOKIE':
        korForm = '성장기';
        break;
      case 'CHAMPION':
        korForm = '성숙기';
        break;
      case 'ULTIMATE':
        korForm = '완전체';
        break;
      case 'MEGA':
        korForm = '궁극체';
        break;
      case 'ARMOR':
        korForm = '아머체';
        break;
      case 'D_REAPER':
        korForm = '디·리퍼';
        break;
      case 'UNKNOWN':
        korForm = '불명';
        break;
      case 'HYBRID':
        korForm = '하이브리드체';
        break;
      case 'APPMON':
        korForm = '어플몬';
        break;
      case 'STND':
        korForm = '스탠다드/어플몬';
        break;
      case 'SUP':
        korForm = '슈퍼/어플몬';
        break;
      case 'ULT':
        korForm = '얼티메이트/어플몬';
        break;
      case 'GOD':
        korForm = '갓/어플몬';
        break;
      default:
        korForm = englishForm; // 매칭되는 한글명이 없으면 영문 그대로 반환
    }
    
    return korForm;
  }
  
  // 표시용으로 복합 형태에서 주 형태만 추출하는 메서드
  String getDisplayFormName(String englishForm) {
    String korForm = getKorFormName(englishForm);
    
    // "/"가 포함된 경우 앞부분만 반환
    if (korForm.contains('/')) {
      return korForm.split('/')[0].trim();
    }
    
    return korForm;
  }

  List<DigimonCard> getRecentCards(int limit) {
    if (!_isInitialized) {
      _initializeSync();
    }
    
    // 등록일 기준으로 최신 카드 반환
    final cards = _allCards.values.toList();
    cards.sort((a, b) => (b.releaseDate ?? DateTime(1970))
        .compareTo(a.releaseDate ?? DateTime(1970)));
    
    return cards.take(limit).toList();
  }
  
  List<DigimonCard> searchCardsByNumber(String cardNoPrefix) {
    if (!_isInitialized) {
      _initializeSync();
    }
    
    final result = <DigimonCard>[];
    
    // 카드 번호로 검색
    for (final card in _allCardsByCardNo.values) {
      if (card.cardNo != null && 
          card.cardNo!.toLowerCase().contains(cardNoPrefix.toLowerCase())) {
        result.add(card);
      }
    }
    
    return result;
  }
  
  List<DigimonCard> searchCardsByText(String searchText) {
    if (!_isInitialized) {
      _initializeSync();
    }
    
    if (searchText.isEmpty) {
      return getRecentCards(10);
    }
    
    final result = <DigimonCard>[];
    final searchLower = searchText.toLowerCase();

    // 카드 이름으로 검색
    for (final card in _allCards.values) {
      if (card.getDisplayName() != null && 
          card.getDisplayName()!.toLowerCase().startsWith(searchLower) &&
          card.isParallel == false
          ) {
        // 중복 카드 방지
        if (!result.any((c) => c.cardId == card.cardId)) {
          result.add(card);
        }
      }
    }
    
    result.sort((a, b) => (a.sortString ?? '').compareTo(b.sortString ?? ''));
    return result;
  }


} 