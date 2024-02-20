import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

import '../model/card.dart';
import 'card/card_widget.dart';

class DeckScrollGridView extends StatefulWidget {
  final Map<DigimonCard, int> deckCount;
  final List<DigimonCard> deck;
  final int rowNumber;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(DigimonCard) cardPressEvent;

  const DeckScrollGridView(
      {super.key,
      required this.deckCount,
      required this.rowNumber,
      this.mouseEnterEvent,  required this.cardPressEvent, required this.deck});

  @override
  State<DeckScrollGridView> createState() => _DeckScrollGridViewState();
}

class _DeckScrollGridViewState extends State<DeckScrollGridView> {
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
                      cardPressEvent: widget.cardPressEvent

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
