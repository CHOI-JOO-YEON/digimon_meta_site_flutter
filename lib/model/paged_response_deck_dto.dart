import 'deck_response_dto.dart';
import 'deck_search_parameter.dart';

class PagedResponseDeckDto {
  List<DeckResponseDto> decks;
  int currentPage;
  int totalPages;
  int totalElements;

  PagedResponseDeckDto({
    required this.decks,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });

  factory PagedResponseDeckDto.fromJson(Map<String, dynamic> json) {
    return PagedResponseDeckDto(
      decks: List<DeckResponseDto>.from(json['decks'].map((x) => DeckResponseDto.fromJson(x))),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
    );
  }
}
