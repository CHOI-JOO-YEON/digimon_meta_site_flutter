import 'dart:collection';

class DeckSearchParameter {
  bool isMyDeck;
  String searchString = "";
  var colors = ["RED", "BLUE", "YELLOW", "GREEN", "BLACK", "PURPLE", "WHITE"];
  int colorOperation = 0;
  int page = 1;
  int size = 10;
  int? formatId;
  int? limitId;
  bool isOnlyValidDeck = true;

  DeckSearchParameter({required this.isMyDeck});

  void updateFormatId(int newFormatId) {
    formatId = newFormatId;
  }

  void updatePage(int newPage) {
    page = newPage;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'isMyDeck': isMyDeck,
      'searchString': searchString,
      'colors': colors,
      'page': page,
      'size': size,
      'formatId': formatId,
      'colorOperation': colorOperation,
      'limitId':limitId,
      'isOnlyValidDeck' : isOnlyValidDeck
    };
    return data;
  }
}
