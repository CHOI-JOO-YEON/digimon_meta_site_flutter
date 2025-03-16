import 'package:digimon_meta_site_flutter/model/format_deck_count_dto.dart';
import 'package:flutter/foundation.dart';
import '../api/deck_api.dart';

class FormatDeckCountProvider with ChangeNotifier {
  static final FormatDeckCountProvider _instance =
      FormatDeckCountProvider._internal();

  Map<int, int> formatAllDeckCount = {};
  Map<int, int> formatMyDeckCount = {};
  bool isLoading = false;
  
  DeckApi _deckApi = DeckApi();

  factory FormatDeckCountProvider() {
    return _instance;
  }

  FormatDeckCountProvider._internal();

  void setFormatMyDeckCount(FormatDeckCountDto dto) {
    formatMyDeckCount = dto.formatMyDeckCount;
    notifyListeners();
  }

  void setFormatAllDeckCount(FormatDeckCountDto dto) {
    formatAllDeckCount = dto.formatAllDeckCount;
    notifyListeners();
  }

  int getFormatDeckCount(int formatId, bool isMyDeck) {
    return (isMyDeck
            ? formatMyDeckCount[formatId]
            : formatAllDeckCount[formatId]) ??
        0;
  }
  
  Future<void> loadDeckCounts() async {
    if (isLoading) return;
    
    isLoading = true;
    try {
      FormatDeckCountDto? deckCounts = await _deckApi.getDeckCount();
      if (deckCounts != null) {
        formatAllDeckCount = deckCounts.formatAllDeckCount;
        formatMyDeckCount = deckCounts.formatMyDeckCount;
        notifyListeners();
      }
    } catch (e) {
    } finally {
      isLoading = false;
    }
  }
}
