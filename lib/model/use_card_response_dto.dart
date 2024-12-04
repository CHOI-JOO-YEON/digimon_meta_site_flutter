import 'package:digimon_meta_site_flutter/model/used_card_info.dart';

class UseCardResponseDto{
  List<UsedCardInfo> usedCardList=[];
  int totalCount=0;
  bool initialize = false;
  UseCardResponseDto({
    required this.usedCardList,
    required this.totalCount,
    required this.initialize
  });

  factory UseCardResponseDto.fromJson(Map<String, dynamic> json) {
    return UseCardResponseDto(
      usedCardList: (json['useCardList'] as List<dynamic>)
          .map((item) => UsedCardInfo.fromJson(item))
          .toList(),
      totalCount: json['totalCount'],
      initialize: true
    );
  }

}