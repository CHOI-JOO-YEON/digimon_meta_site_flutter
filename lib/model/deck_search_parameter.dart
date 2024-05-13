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
  bool isOnlyValidDeckAll = true;
  bool isOnlyValidDeckMy = false;

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
      'isOnlyValidDeck' : isMyDeck?isOnlyValidDeckMy:isOnlyValidDeckAll
    };
    return data;
  }

  factory DeckSearchParameter.fromJson(Map<String, dynamic> json) {
    return DeckSearchParameter(isMyDeck: json['isMyDeck'] as bool)
      ..searchString = json['searchString'] as String? ?? ""
      ..colors = (json['colors'] as List<dynamic>?)?.map((color) => color.toString()).toList() ?? ["RED", "BLUE", "YELLOW", "GREEN", "BLACK", "PURPLE", "WHITE"]
      ..colorOperation = json['colorOperation'] as int? ?? 0
      ..page = json['page'] as int? ?? 1
      ..size = json['size'] as int? ?? 10
      ..formatId = json['formatId'] as int?
      ..limitId = json['limitId'] as int?
      ..isOnlyValidDeckAll = json['isOnlyValidDeck'] as bool? ?? true
      ..isOnlyValidDeckMy = json['isOnlyValidDeck'] as bool? ?? false;
  }
}
