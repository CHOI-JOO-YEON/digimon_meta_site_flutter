import 'package:intl/intl.dart';

class LimitDto {
  int id;
  DateTime restrictionBeginDate;
  Map<String,int> allowedQuantityMap;
  List<LimitPair> limitPairs;

  LimitDto({
    required this.id,
    required this.restrictionBeginDate,
    required this.allowedQuantityMap,
    required this.limitPairs
  });

  factory LimitDto.fromJson(Map<String, dynamic> json) {
    Map<String,int> map = {};
    var banList = List<String>.from(json['banList']);
    for (var s in banList) {
      map[s]=0;
    }
    var restrictList = List<String>.from(json['restrictList']);
    for (var s in restrictList) {
      map[s]=1;
    }

    List<LimitPair> limitPairs = [];
    if (json['limitPairList'] != null) {
      limitPairs = (json['limitPairList'] as List)
          .map((pairJson) => LimitPair.fromJson(pairJson))
          .toList();
    }

    return LimitDto(
      id: json['id'],
      restrictionBeginDate: DateFormat('yyyy-MM-dd').parse(json['restrictionBeginDate']),
      allowedQuantityMap: map,
      limitPairs: limitPairs
    );
  }

  static List<LimitDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => LimitDto.fromJson(json)).toList();
  }
}

class LimitPair {
  List<String> acardPairNos;
  List<String> bcardPairNos;

  LimitPair({
    required this.acardPairNos,
    required this.bcardPairNos,
  });

  factory LimitPair.fromJson(Map<String, dynamic> json) {
    return LimitPair(
      acardPairNos: List<String>.from(json['acardPairNos']),
      bcardPairNos: List<String>.from(json['bcardPairNos']),
    );
  }
}