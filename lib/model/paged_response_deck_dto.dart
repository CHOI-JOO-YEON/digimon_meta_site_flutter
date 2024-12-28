import 'deck-view.dart';
import 'deck_search_parameter.dart';

class PagedResponseDeckDto {
  List<DeckView> decks;
  int currentPage;
  int totalPages;
  int totalElements;
  Map<int, int> formatDeckCount;

  PagedResponseDeckDto({
    required this.decks,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.formatDeckCount,
  });

  factory PagedResponseDeckDto.fromJson(Map<String, dynamic> json) {
    return PagedResponseDeckDto(
      decks: List<DeckView>.from(json['decks'].map((x) => DeckView.fromJson(x))),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      formatDeckCount: (json['formatDeckCount'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
            int.parse(key), 
            value as int    
        ),
      ),
    );
  }
}
