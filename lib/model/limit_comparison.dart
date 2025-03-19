import 'package:digimon_meta_site_flutter/model/limit_dto.dart';

class LimitComparison {
  final LimitDto currentLimit;
  final LimitDto? previousLimit;
  
  // Cards that were newly banned in the current limit
  final List<String> newlyBannedCards;
  
  // Cards that were newly restricted in the current limit
  final List<String> newlyRestrictedCards;
  
  // Cards that were removed from ban list in the current limit
  final List<String> removedBanCards;
  
  // Cards that were removed from restriction list in the current limit
  final List<String> removedRestrictCards;
  
  // New limit pairs in the current limit
  final List<LimitPair> newLimitPairs;
  
  // Removed limit pairs in the current limit
  final List<LimitPair> removedLimitPairs;

  LimitComparison({
    required this.currentLimit,
    this.previousLimit,
    required this.newlyBannedCards,
    required this.newlyRestrictedCards,
    required this.removedBanCards,
    required this.removedRestrictCards,
    required this.newLimitPairs,
    required this.removedLimitPairs,
  });

  /// Factory method to create a comparison between two limits
  static LimitComparison compare(LimitDto currentLimit, LimitDto? previousLimit) {
    if (previousLimit == null) {
      // No previous limit, so everything in the current limit is new
      final List<String> newlyBannedCards = [];
      final List<String> newlyRestrictedCards = [];
      
      currentLimit.allowedQuantityMap.forEach((cardNo, quantity) {
        if (quantity == 0) {
          newlyBannedCards.add(cardNo);
        } else if (quantity == 1) {
          newlyRestrictedCards.add(cardNo);
        }
      });
      
      return LimitComparison(
        currentLimit: currentLimit,
        previousLimit: null,
        newlyBannedCards: newlyBannedCards,
        newlyRestrictedCards: newlyRestrictedCards,
        removedBanCards: [],
        removedRestrictCards: [],
        newLimitPairs: currentLimit.limitPairs,
        removedLimitPairs: [],
      );
    }
    
    // Identify new banned cards
    final List<String> newlyBannedCards = [];
    final List<String> newlyRestrictedCards = [];
    final List<String> removedBanCards = [];
    final List<String> removedRestrictCards = [];
    
    // Check for newly banned or restricted cards
    currentLimit.allowedQuantityMap.forEach((cardNo, quantity) {
      // Card is banned (quantity = 0)
      if (quantity == 0) {
        if (!previousLimit.allowedQuantityMap.containsKey(cardNo)) {
          newlyBannedCards.add(cardNo);
        } else if (previousLimit.allowedQuantityMap[cardNo]! > 0) {
          // It was restricted before, now banned
          newlyBannedCards.add(cardNo);
        }
      }
      // Card is restricted (quantity = 1)
      else if (quantity == 1) {
        if (!previousLimit.allowedQuantityMap.containsKey(cardNo)) {
          newlyRestrictedCards.add(cardNo);
        }
      }
    });
    
    // Check for cards removed from ban or restrict lists
    previousLimit.allowedQuantityMap.forEach((cardNo, quantity) {
      // Card was banned before
      if (quantity == 0) {
        if (!currentLimit.allowedQuantityMap.containsKey(cardNo)) {
          removedBanCards.add(cardNo);
        } else if (currentLimit.allowedQuantityMap[cardNo]! > 0) {
          // It was banned before, now something else
          removedBanCards.add(cardNo);
        }
      }
      // Card was restricted before
      else if (quantity == 1) {
        if (!currentLimit.allowedQuantityMap.containsKey(cardNo)) {
          removedRestrictCards.add(cardNo);
        } else if (currentLimit.allowedQuantityMap[cardNo]! != 1) {
          // It's no longer restricted
          removedRestrictCards.add(cardNo);
        }
      }
    });
    
    // 새롭게 추가된 페어와 제거된 페어 비교
    final List<LimitPair> newLimitPairs = [];
    final List<LimitPair> removedLimitPairs = [];
    
    // 이전과 현재 페어를 비교하여 새 페어 식별
    for (var currentPair in currentLimit.limitPairs) {
      bool found = false;
      for (var previousPair in previousLimit.limitPairs) {
        // 두 페어의 A 카드 목록과 B 카드 목록이 동일한지 비교
        if (_arePairsEqual(currentPair, previousPair)) {
          found = true;
          break;
        }
      }
      if (!found) {
        // 이전 금제에 없던 새로운 페어
        newLimitPairs.add(currentPair);
      }
    }
    
    // 이전 페어 중 제거된 페어 식별
    for (var previousPair in previousLimit.limitPairs) {
      bool found = false;
      for (var currentPair in currentLimit.limitPairs) {
        if (_arePairsEqual(previousPair, currentPair)) {
          found = true;
          break;
        }
      }
      if (!found) {
        // 현재 금제에서 제거된 페어
        removedLimitPairs.add(previousPair);
      }
    }
    
    return LimitComparison(
      currentLimit: currentLimit,
      previousLimit: previousLimit,
      newlyBannedCards: newlyBannedCards,
      newlyRestrictedCards: newlyRestrictedCards,
      removedBanCards: removedBanCards,
      removedRestrictCards: removedRestrictCards,
      newLimitPairs: newLimitPairs,
      removedLimitPairs: removedLimitPairs,
    );
  }
  
  /// 두 LimitPair가 동일한지 비교하는 헬퍼 메서드
  static bool _arePairsEqual(LimitPair pair1, LimitPair pair2) {
    // 두 리스트의 길이가 다르면 다른 페어
    if (pair1.acardPairNos.length != pair2.acardPairNos.length ||
        pair1.bcardPairNos.length != pair2.bcardPairNos.length) {
      return false;
    }
    
    // A 카드 목록과 B 카드 목록이 모두 같은 카드를 포함하는지 확인
    bool sameA = _areCardListsEqual(pair1.acardPairNos, pair2.acardPairNos);
    bool sameB = _areCardListsEqual(pair1.bcardPairNos, pair2.bcardPairNos);
    
    return sameA && sameB;
  }
  
  /// 두 카드 리스트가 동일한 카드를 포함하는지 비교하는 헬퍼 메서드
  static bool _areCardListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    // 정렬된 복사본을 생성하여 비교
    final sortedList1 = List<String>.from(list1)..sort();
    final sortedList2 = List<String>.from(list2)..sort();
    
    for (int i = 0; i < sortedList1.length; i++) {
      if (sortedList1[i] != sortedList2[i]) {
        return false;
      }
    }
    
    return true;
  }
} 