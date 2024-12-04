import 'card.dart';

class UsedCardInfo {
  int rank;
  double ratio;
  int count;
  DigimonCard card;

  UsedCardInfo({
    required this.rank,
    required this.ratio,
    required this.count,
    required this.card,
  });

  factory UsedCardInfo.fromJson(Map<String, dynamic> json) {
    return UsedCardInfo(
      rank: json['rank'],
      ratio: json['ratio'],
      count: json['count'],
      card: DigimonCard.fromJson(json['card']),
    );
  }

  static List<UsedCardInfo> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UsedCardInfo.fromJson(json)).toList();
  }
}