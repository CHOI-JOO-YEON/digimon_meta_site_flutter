import 'package:flutter/material.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_view_widget.dart';

class FullDeckViewerModal extends StatelessWidget {
  final DeckBuild deck;
  final Function(DigimonCard) cardPressEvent;
  final Function(DeckBuild) import;
  final Function(SearchParameter)? searchWithParameter;
  final CardOverlayService cardOverlayService;

  const FullDeckViewerModal({
    super.key,
    required this.deck,
    required this.cardPressEvent,
    required this.import,
    this.searchWithParameter,
    required this.cardOverlayService,
  });

  static Future<void> show({
    required BuildContext context,
    required DeckBuild deck,
    required Function(DigimonCard) cardPressEvent,
    required Function(DeckBuild) import,
    Function(SearchParameter)? searchWithParameter,
    required CardOverlayService cardOverlayService,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => FullDeckViewerModal(
        deck: deck,
        cardPressEvent: cardPressEvent,
        import: import,
        searchWithParameter: searchWithParameter,
        cardOverlayService: cardOverlayService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.95,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더 영역
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '덱 상세보기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        deck.deckName.isEmpty ? 'My Deck' : deck.deckName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 덱 상세 내용
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DeckBuilderView(
                  deck: deck,
                  cardPressEvent: cardPressEvent,
                  import: import,
                  searchWithParameter: searchWithParameter,
                  cardOverlayService: cardOverlayService,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 