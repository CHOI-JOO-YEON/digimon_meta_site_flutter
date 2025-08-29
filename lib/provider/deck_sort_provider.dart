import 'package:flutter/foundation.dart';
import '../model/card.dart';

class SortCriterion {
  String field;
  bool ascending; // true for ascending, false for descending
  Map<String, int>? orderMap; // For cardType and colors

  SortCriterion(this.field, {this.ascending = true, this.orderMap});

  @override
  String toString() {
    return 'SortCriterion{field: $field, ascending: $ascending, orderMap: $orderMap}';
  }
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
    SortCriterion('releaseDate', ascending: true),
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
    SortCriterion('releaseDate', ascending: true),
    SortCriterion('hasXAntibody', ascending: true),
  ];

  static final Map<String, String> _sortPriorityTextMap = {
    'cardType': '카드 타입',
    'lv': '레벨',
    'color1': '색상1',
    'color2': '색상2',
    'playCost': '등장/사용 코스트',
    'sortString': '카드 넘버',
    'isParallel': '패럴렐 우선',
    'dp': 'DP',
    'cardName': '카드 이름',
    'releaseDate' : '발매 일자',
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
          int aOrder = criterion.orderMap?[a.cardType] ?? 0;
          int bOrder = criterion.orderMap?[b.cardType] ?? 0;
          comparison = aOrder.compareTo(bOrder);
          break;
        case 'lv':
          comparison =
              (a.lv ?? 0).compareTo(b.lv ?? 0);
          break;
        case 'color1':
          int aOrder = criterion.orderMap?[a.color1] ?? 0;
          int bOrder = criterion.orderMap?[b.color1] ?? 0;
          comparison = aOrder.compareTo(bOrder);
          break;
        case 'color2':
          int aOrder = criterion.orderMap?[a.color2] ?? 0;
          int bOrder = criterion.orderMap?[b.color2] ?? 0;
          comparison = aOrder.compareTo(bOrder);
          break;
        case 'playCost':
          comparison = (a.playCost ?? 0)
              .compareTo(b.playCost ?? 0);
          break;
        case 'dp':
          comparison =
              (a.dp ?? 0).compareTo(b.dp ?? 0);
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
        case 'releaseDate':
          comparison =
          (a.releaseDate?? DateTime(0)).compareTo(b.releaseDate?? DateTime(0));
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

  List<SortCriterion> getOriginalSortPriority() {
    return List.from(_originalSortPriority);
  }
}
