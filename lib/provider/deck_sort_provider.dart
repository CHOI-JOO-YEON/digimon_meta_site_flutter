import 'package:flutter/foundation.dart';
import '../model/card.dart';

class SortCriterion {
  String field;
  bool ascending; // true for ascending, false for descending
  Map<String, int>? orderMap; // For cardType and colors

  SortCriterion(this.field, {this.ascending = true, this.orderMap});
}

class DeckSortProvider with ChangeNotifier {
  static final DeckSortProvider _instance = DeckSortProvider._internal();

  factory DeckSortProvider() {
    return _instance;
  }

  DeckSortProvider._internal();

  List<SortCriterion> sortPriority = [
    SortCriterion('cardType', orderMap: {
      'DIGIMON': 1,
      'TAMER': 2,
      'OPTION': 3,
    }),
    SortCriterion('lv', ascending: true),
    SortCriterion('color1', orderMap: {
      'RED': 1,
      'BLUE': 2,
      'YELLOW': 3,
      'GREEN': 4,
      'BLACK': 5,
      'PURPLE': 6,
      'WHITE': 7,
    }),
    SortCriterion('color2', orderMap: {
      'RED': 1,
      'BLUE': 2,
      'YELLOW': 3,
      'GREEN': 4,
      'BLACK': 5,
      'PURPLE': 6,
      'WHITE': 7,
    }),
    SortCriterion('playCost', ascending: true),
    SortCriterion('sortString', ascending: true),
    SortCriterion('isParallel', ascending: true),
    SortCriterion('dp', ascending: true),
    SortCriterion('cardName', ascending: true),
    SortCriterion('hasXAntibody', ascending: true),
  ];

  static final List<SortCriterion> _originalSortPriority = [
    SortCriterion('cardType', orderMap: {
      'DIGIMON': 1,
      'TAMER': 2,
      'OPTION': 3,
    }),
    SortCriterion('lv', ascending: true),
    SortCriterion('color1', orderMap: {
      'RED': 1,
      'BLUE': 2,
      'YELLOW': 3,
      'GREEN': 4,
      'BLACK': 5,
      'PURPLE': 6,
      'WHITE': 7,
    }),
    SortCriterion('color2', orderMap: {
      'RED': 1,
      'BLUE': 2,
      'YELLOW': 3,
      'GREEN': 4,
      'BLACK': 5,
      'PURPLE': 6,
      'WHITE': 7,
    }),
    SortCriterion('playCost', ascending: true),
    SortCriterion('sortString', ascending: true),
    SortCriterion('isParallel', ascending: true),
    SortCriterion('dp', ascending: true),
    SortCriterion('cardName', ascending: true),
    SortCriterion('hasXAntibody', ascending: true),
  ];

  static final Map<String, String> _sortPriorityTextMap = {
    'cardType': '카드 타입',
    'lv': '레벨',
    'color1': '색상1',
    'color2': '색상2',
    'playCost': '등장/사용 코스트',
    'sortString': '정렬 문자열',
    'isParallel': '패럴렐 우선',
    'dp': 'DP',
    'cardName': '카드 이름',
    'hasXAntibody': 'X항체 포함 여부',
  };

  String getSortPriorityKor(String sortString) {
    return _sortPriorityTextMap[sortString] ?? '';
  }

  static final int max = 2147483646;

  int digimonCardComparator(DigimonCard a, DigimonCard b) {
    for (var criterion in sortPriority) {
      int comparison = 0;
      switch (criterion.field) {
        case 'cardType':
          int aOrder = criterion.orderMap?[a.cardType] ?? max;
          int bOrder = criterion.orderMap?[b.cardType] ?? max;
          comparison = aOrder.compareTo(bOrder);
          break;
        case 'lv':
          comparison =
              (a.lv ?? double.infinity).compareTo(b.lv ?? double.infinity);
          break;
        case 'color1':
          int aOrder = criterion.orderMap?[a.color1] ?? max;
          int bOrder = criterion.orderMap?[b.color1] ?? max;
          comparison = aOrder.compareTo(bOrder);
          break;
        case 'color2':
          int aOrder = criterion.orderMap?[a.color2] ?? max;
          int bOrder = criterion.orderMap?[b.color2] ?? max;
          comparison = aOrder.compareTo(bOrder);
          break;
        case 'playCost':
          comparison = (a.playCost ?? double.infinity)
              .compareTo(b.playCost ?? double.infinity);
          break;
        case 'dp':
          comparison =
              (a.dp ?? double.infinity).compareTo(b.dp ?? double.infinity);
          break;
        case 'sortString':
          comparison = (a.sortString ?? '').compareTo(b.sortString ?? '');
          break;
        case 'cardName':
          comparison = (a.getDisplayName() ?? '').compareTo(b.getDisplayName() ?? '');
          break;
        case 'isParallel':
          comparison =
              (a.isParallel! ? -1 : 1).compareTo(b.isParallel! ? -1 : 1);
          break;
        case 'hasXAntibody':
          bool aHasXAntibody = a.getDisplayName()?.contains('X항체') ?? false;
          bool bHasXAntibody = b.getDisplayName()?.contains('X항체') ?? false;
          comparison =
              (aHasXAntibody ? 1 : 0).compareTo(bHasXAntibody ? 1 : 0);
          break;
        default:
          break;
      }

      if (comparison != 0) {
        if (!criterion.ascending) {
          comparison = -comparison;
        }
        return comparison;
      }
    }
    return 0;
  }

  void setSortPriority(List<SortCriterion> newPriority) {
    sortPriority = newPriority;
    notifyListeners(); // 변경 사항 알림
  }

  void reset() {
    sortPriority = List.from(_originalSortPriority);
    notifyListeners();
  }
}
