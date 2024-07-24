import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

import '../../model/card.dart';
import '../../service/card_service.dart';
import '../card/card_widget.dart';

class DeckScrollGridView extends StatefulWidget {
  final Map<DigimonCard, int> deckCount;
  final List<DigimonCard> deck;
  final int rowNumber;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(DigimonCard)? cardPressEvent;
  final Function(DigimonCard)? onLongPress;
  final Function(int)? searchNote;

  const DeckScrollGridView(
      {super.key,
      required this.deckCount,
      required this.rowNumber,
      this.mouseEnterEvent,   this.cardPressEvent, required this.deck,  this.onLongPress, this.searchNote});

  @override
  State<DeckScrollGridView> createState() => _DeckScrollGridViewState();
}


class _DeckScrollGridViewState extends State<DeckScrollGridView> {

  OverlayEntry? _overlayEntry;

  void _showBigImage(BuildContext cardContext, String imgUrl, int index) {
    final RenderBox renderBox = cardContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(cardContext).size.height;
    final screenWidth = MediaQuery.of(cardContext).size.width;
    final maxHeight = screenHeight * 0.5; // 화면 높이의 절반을 최대 높이로 설정

    final aspectRatio = renderBox.size.width / renderBox.size.height;
    final maxWidth = maxHeight * aspectRatio; // 최대 높이에 맞는 너비 계산

    final bool onRightSide = (index % widget.rowNumber) < widget.rowNumber / 2;
    final double overlayLeft = onRightSide
        ? offset.dx + renderBox.size.width
        : offset.dx - maxWidth;

    final double overlayTop = (offset.dy + maxHeight > screenHeight)
        ? screenHeight - maxHeight
        : offset.dy;

    final double correctedLeft = overlayLeft < 0 ? 0 : overlayLeft;

    final double correctedWidth =
    correctedLeft + maxWidth > screenWidth ? screenWidth - correctedLeft : maxWidth;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: correctedLeft,
        top: overlayTop,
        width: correctedWidth,
        height: correctedWidth / aspectRatio,
        child: Image.network(imgUrl, fit: BoxFit.cover),
      ),
    );

    Overlay.of(cardContext)?.insert(_overlayEntry!);
  }
  void _hideBigImage() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.rowNumber,
            childAspectRatio: 0.715,
            // crossAxisSpacing:  (constraints.maxWidth / widget.rowNumber) * 0.1,
            // mainAxisSpacing:  (constraints.maxWidth / widget.rowNumber) * 0.1,
          ),
          itemCount: widget.deck.length,
          itemBuilder: (context, index) {
            DigimonCard card = widget.deck[index];
            int count = widget.deckCount[card]!;

            return Padding(
              // padding: EdgeInsets.all( (constraints.maxWidth / widget.rowNumber) * 0.08),
              padding: EdgeInsets.all( 0),
              child: Stack(
                  children: [
                    CustomCard(
                      // mouseEnterEvent: widget.mouseEnterEvent,
                      card: card,
                      width: (constraints.maxWidth / widget.rowNumber) * 0.99,
                      cardPressEvent: widget.cardPressEvent,
                      onLongPress: widget.onLongPress,
                      onHover: (context) =>
                          _showBigImage(context, card.imgUrl!, index),
                      onExit: _hideBigImage,
                      searchNote: widget.searchNote,
                      onDoubleTab: () => CardService().showImageDialog(
                          context,card, widget.searchNote),
                    ),
                    Positioned(
                      left:
                          ((constraints.maxWidth / widget.rowNumber) * 0.9) / 9,
                      bottom:
                          ((constraints.maxWidth / widget.rowNumber) * 0.9) / 12,
                      child: FittedBox(
                        fit: BoxFit.scaleDown, // 텍스트가 너무 커지는 것을 방지합니다.
                        child: StrokeText(
                          text: '$count',
                          textStyle: TextStyle(
                              fontSize:
                                  ((constraints.maxWidth / widget.rowNumber) *
                                          0.9) /
                                      6,
                              color: Colors.black),
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
