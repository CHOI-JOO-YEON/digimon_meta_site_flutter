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
  const DeckScrollGridView(
      {super.key,
      required this.deckCount,
      required this.rowNumber,
      required this.deck,
      this.searchNote,
      this.addCard,
      this.removeCard, required this.cardOverlayService, required this.isTama, });

  @override
  State<DeckScrollGridView> createState() => _DeckScrollGridViewState();
}

class _DeckScrollGridViewState extends State<DeckScrollGridView>
    with WidgetsBindingObserver {
  Size _lastSize = Size.zero; // 이전 화면 크기를 저장하는 변수
  @override
  void initState() {
    super.initState();
   
    WidgetsBinding.instance.addObserver(this); // Observer 등록
    _scrollController.addListener(() {
      // 스크롤이 발생할 때 오버레이 위치 업데이트
      widget.cardOverlayService.removeAllOverlays();
    });
  }

  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    super.dispose();
  }

  @override
  void didUpdateWidget(DeckScrollGridView oldWidget) {
    if (oldWidget.rowNumber != widget.rowNumber) {
      widget.cardOverlayService.removeAllOverlays();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final Size newSize = MediaQuery.of(context).size;

    if (newSize != _lastSize) {
      widget.cardOverlayService.removeAllOverlays(); // 오버레이 제거
      _lastSize = newSize; // 새로운 사이즈로 업데이트
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          shrinkWrap: true, // 내부 요소에 따라 그리드 높이 조절
          controller: _scrollController, // ScrollController 연결
          physics: NeverScrollableScrollPhysics(), // 그리드뷰 자체 스크롤 비활성화
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.rowNumber,
            childAspectRatio: 0.715,
          ),
          itemCount: widget.deck.length,
          itemBuilder: (context, index) {
            DigimonCard card = widget.deck[index];
            int count = widget.deckCount[card]!;

            GlobalKey cardKey = GlobalKey();

            return Padding(
              padding: EdgeInsets.all(0),
              child: Stack(
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
                                    {widget.cardOverlayService.removeAllOverlays()}
                                },
                            () => widget.addCard!(card),widget.isTama);
                      }
                    },
                    onLongPress: () => CardService()
                        .showImageDialog(context, card, widget.searchNote),
                    onHover: (context) {
                      final RenderBox renderBox = cardKey.currentContext!
                          .findRenderObject() as RenderBox;
                      widget.cardOverlayService.showBigImage(context, card.imgUrl!,
                          renderBox, widget.rowNumber, index);
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
                          fontSize: ((constraints.maxWidth / widget.rowNumber) *
                                  0.9) /
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
              ),
            );
          },
        );
      },
    );
  }
}
