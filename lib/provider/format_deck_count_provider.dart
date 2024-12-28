import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_collect_dto.dart';
import 'package:flutter/foundation.dart';
import '../api/collect_api.dart';
import '../model/paged_response_deck_dto.dart';

class FormatDeckCountProvider with ChangeNotifier {
  static final FormatDeckCountProvider _instance =
      FormatDeckCountProvider._internal();

  Map<int, int> formatAllDeckCount = {};
  Map<int, int> formatMyDeckCount = {};

  factory FormatDeckCountProvider() {
    return _instance;
  }

  FormatDeckCountProvider._internal();

  void setFormatMyDeckCount(PagedResponseDeckDto dto) {
    formatMyDeckCount = dto.formatDeckCount;
    notifyListeners();
  }

  void setFormatAllDeckCount(PagedResponseDeckDto dto) {
    formatAllDeckCount = dto.formatDeckCount;
    notifyListeners();
  }

  int getFormatDeckCount(int formatId, bool isMyDeck) {
    return (isMyDeck
            ? formatMyDeckCount[formatId]
            : formatAllDeckCount[formatId]) ??
        0;
  }
}
