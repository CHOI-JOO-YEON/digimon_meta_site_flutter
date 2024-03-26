import 'package:flutter/foundation.dart';
import 'package:digimon_meta_site_flutter/api/limit_api.dart';
import 'package:digimon_meta_site_flutter/enums/special_limit_card_enum.dart';
import '../model/limit_dto.dart';

class LimitProvider with ChangeNotifier {
  Map<DateTime, LimitDto> _limits = {};
  LimitDto? _selectedLimit;

  Map<DateTime, LimitDto> get limits => _limits;
  LimitDto? get selectedLimit => _selectedLimit;

  Future<void> initialize() async {
    var response = await LimitApi().getLimits();
    if (response != null) {
      for (var limit in response) {
        _limits[limit.restrictionBeginDate] = limit;
      }
    }

    _selectedLimit = getCurrentLimit();
    notifyListeners();
  }

  void updateSelectLimit(DateTime dateTime) {
    _selectedLimit = _limits[dateTime];
    notifyListeners();
  }

  int getCardAllowedQuantity(String cardNo) {
    if (_selectedLimit == null) {
      return -1;
    }
    if (_selectedLimit!.allowedQuantityMap.containsKey(cardNo)) {
      return _selectedLimit!.allowedQuantityMap[cardNo]!;
    }
    return SpecialLimitCard.getLimitByCardNo(cardNo);
  }

  LimitDto? getCurrentLimit() {
    DateTime currentDate = DateTime.now();
    LimitDto? latestLimit;
    for (var limitDate in _limits.keys) {
      if (limitDate.isBefore(currentDate) || limitDate == currentDate) {
        if (latestLimit == null || limitDate.isAfter(latestLimit.restrictionBeginDate)) {
          latestLimit = _limits[limitDate];
        }
      }
    }
    return latestLimit;
  }
}