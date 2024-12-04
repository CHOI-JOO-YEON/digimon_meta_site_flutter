import 'package:digimon_meta_site_flutter/model/card.dart';

class CardResponseDto {
  int? totalPages;
  int? currentPage;
  int? totalElements;
  List<DigimonCard>? cards;

  CardResponseDto({
    this.totalPages,
    this.currentPage,
    this.totalElements,
    this.cards,
  });

  factory CardResponseDto.fromJson(Map<String, dynamic> json) => CardResponseDto(
    totalPages: json['totalPages'],
    currentPage: json['currentPage'],
    totalElements: json['totalElements'],
    cards: json['cards'] != null ? List<DigimonCard>.from(json['cards'].map((x) => DigimonCard.fromJson(x))) : null,
  );

}
