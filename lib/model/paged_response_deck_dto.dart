import 'deck-view.dart';
import 'deck_search_parameter.dart';

class PagedResponseDeckDto {
  List<DeckView> decks;
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
      decks: List<DeckView>.from(json['decks'].map((x) => DeckView.fromJson(x))),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
    );
  }
}
