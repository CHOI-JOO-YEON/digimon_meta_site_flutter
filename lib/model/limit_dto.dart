import 'package:intl/intl.dart';

class LimitDto {
  int id;
  DateTime restrictionBeginDate;
  Map<String,int> allowedQuantityMap;

  LimitDto({
    required this.id,
    required this.restrictionBeginDate,
    required this.allowedQuantityMap
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
    return LimitDto(
      id: json['id'],
      restrictionBeginDate: DateFormat('yyyy-MM-dd').parse(json['restrictionBeginDate']),
      allowedQuantityMap: map
    );
  }

  static List<LimitDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => LimitDto.fromJson(json)).toList();
  }

}