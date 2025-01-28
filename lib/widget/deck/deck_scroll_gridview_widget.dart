import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

import '../../model/card.dart';
import '../../service/card_overlay_service.dart';
import '../../service/card_service.dart';
import '../card/card_widget.dart';

class DeckScrollGridView extends StatefulWidget {
  final Map<DigimonCard, int> deckCount;
  final List<DigimonCard> deck;
  final int rowNumber;
  final Function(int)? searchNote;
  final Function(DigimonCard)? addCard;
  final Function(DigimonCard)? removeCard;
  final CardOverlayService cardOverlayService;
  final bool isTama;

  const DeckScrollGridView({
    super.key,
    required this.deckCount,
    required this.rowNumber,
    required this.deck,
    this.searchNote,
    this.addCard,
    this.removeCard,
    required this.cardOverlayService,
    required this.isTama,
  });

  @override
  State<DeckScrollGridView> createState() => _DeckScrollGridViewState();
}

class _DeckScrollGridViewState extends State<DeckScrollGridView>
    with WidgetsBindingObserver {
  Size _lastSize = Size.zero;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this); // Observer 등록
    _scrollController.addListener(() {
      widget.cardOverlayService.removeAllOverlays();
    });
  }

  final ScrollController _scrollController = ScrollController(); 

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(DeckScrollGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowNumber != widget.rowNumber) {
      widget.cardOverlayService.removeAllOverlays();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final Size newSize = MediaQuery.of(context).size;

    if (newSize != _lastSize) {
      widget.cardOverlayService.removeAllOverlays(); 
      _lastSize = newSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.rowNumber,
            childAspectRatio: 0.715,
          ),
          itemCount: widget.deck.length,
          itemBuilder: (context, index) {
            DigimonCard card = widget.deck[index];
            int count = widget.deckCount[card]!;

            GlobalKey cardKey = GlobalKey();

            return Stack(
              children: [
                
                CustomCard(
                  key: cardKey,
                  card: card,
                  width: (constraints.maxWidth / widget.rowNumber) * 0.99,
                  cardPressEvent: (card) {
                    if (widget.removeCard != null) {
                      final RenderBox renderBox = cardKey.currentContext!
                          .findRenderObject() as RenderBox;
                      widget.cardOverlayService.showCardOptions(
                          context,
                          renderBox,
                          () => {
                                widget.removeCard!(card),
                                if (widget.deckCount[card] == null)
                                  {
                                    widget.cardOverlayService
                                        .removeAllOverlays()
                                  }
                              },
                          () => widget.addCard!(card),
                          widget.isTama);
                    }
                  },
                  onLongPress: () => CardService()
                      .showImageDialog(context, card, widget.searchNote, 
                  ),
                  onHover: (context) {
                    final RenderBox renderBox =
                        cardKey.currentContext!.findRenderObject() as RenderBox;
                    widget.cardOverlayService.showBigImage(
                        context,
                        card.getDisplayImgUrl()!,
                        renderBox,
                        widget.rowNumber,
                        index);
                  },
                  onExit: widget.cardOverlayService.hideBigImage,
                  searchNote: widget.searchNote,
                ),
                Positioned(
                  left: ((constraints.maxWidth / widget.rowNumber) * 0.9) / 9,
                  bottom:
                      ((constraints.maxWidth / widget.rowNumber) * 0.9) / 12,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: StrokeText(
                      text: '$count',
                      textStyle: TextStyle(
                        fontSize:
                            ((constraints.maxWidth / widget.rowNumber) * 0.9) /
                                6,
                        color: Colors.black,
                      ),
                      strokeColor: Colors.white,
                      strokeWidth:
                          ((constraints.maxWidth / widget.rowNumber) * 0.9) /
                              30,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
