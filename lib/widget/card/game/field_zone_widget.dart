import 'package:digimon_meta_site_flutter/widget/card/game/draggable_digimon_stack_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class FieldZoneWidget extends StatelessWidget {
  final FieldZone fieldZone;
  final double cardWidth;
  final bool isRaising;

  const FieldZoneWidget(
      {super.key,
      required this.fieldZone,
      required this.cardWidth,
      required this.isRaising});

  @override
  Widget build(BuildContext context) {
    double cardHeight = cardWidth * 1.404;
    double cardSpacing = cardHeight * 0.16;
    List<DigimonCard> cards = fieldZone.stack;
    String id = fieldZone.key;

    final gameState = Provider.of<GameState>(context);
    return ChangeNotifierProvider.value(
      value: fieldZone,
      child: Consumer<FieldZone>(
        builder: (context, fieldZone, child) {
          return Container(
            constraints: BoxConstraints(
              minWidth: cardWidth * 1.1, // 최소 너비를 카드 너비의 1.1배로 설정
              minHeight: cardHeight * 0.8, // 최소 높이 설정
            ),
            padding: EdgeInsets.all(cardWidth * 0.05),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(cardWidth * 0.1)),
            child: DraggableDigimonStackWidget(
              digimonStack: cards,
              id: id,
              cardHeight: cardHeight,
              // cardWidth: cardWidth,
              spacing: cardSpacing,
              children: [
                ...cards.asMap().entries.map((entry) {
                  int index = entry.key;
                  DigimonCard card = entry.value;

                  return Positioned(
                    bottom: index * cardSpacing,
                    child: Draggable<MoveCard>(
                      data: MoveCard(
                          fromId: id,
                          fromStartIndex: index,
                          fromEndIndex: index,
                          restStatus: cards.length == 1 && fieldZone.isRest),
                      feedback: ChangeNotifierProvider.value(
                        value: gameState,
                        child: Material(
                          color: Colors.transparent,
                          child: CardWidget(
                            card: card,
                            cardWidth: cardWidth,
                            rest: () => {},
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: CardWidget(
                          card: card,
                          cardWidth: cardWidth,
                          rest: () {},
                        ),
                      ),
                      child: Transform.rotate(
                        angle: fieldZone.isRest && index == cards.length - 1
                            ? -pi / 8
                            : 0.0,
                        child: CardWidget(
                          card: card,
                          cardWidth: cardWidth,
                          rest: () {
                            if (index == cards.length - 1) {
                              fieldZone.updateRestStatus(true, gameState);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                }),
                if (cards.isNotEmpty)
                  Positioned(
                    bottom: cardHeight + cardSpacing * (cards.length - 2),
                    left: 0,
                    child: Draggable<MoveCard>(
                      data: MoveCard(
                          fromId: id,
                          fromStartIndex: 0,
                          fromEndIndex: cards.length - 1,
                          restStatus: fieldZone.isRest),
                      feedback: ChangeNotifierProvider.value(
                        value: gameState,
                        child: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: cardWidth,
                            height:
                                cardHeight + cardSpacing * (cards.length - 1),
                            child: Stack(
                              children: cards.asMap().entries.map((entry) {
                                int index = entry.key;
                                DigimonCard card = entry.value;
                                return Positioned(
                                  bottom: index * cardSpacing,
                                  right: 0,
                                  child: CardWidget(
                                    card: card,
                                    cardWidth: cardWidth,
                                    rest: () {},
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(),
                      onDragStarted: () {
                        gameState.updateDragStatus(id, true);
                      },
                      onDragEnd: (details) {
                        gameState.updateDragStatus(id, false);
                      },
                      onDragCompleted: () {
                        gameState.updateDragStatus(id, false);
                      },
                      child: Icon(
                        Icons.radio_button_on,
                        color: Colors.blue,
                        size: cardWidth * 0.25,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
