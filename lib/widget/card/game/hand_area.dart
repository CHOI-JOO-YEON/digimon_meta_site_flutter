import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class HandArea extends StatelessWidget {
  final double cardWidth;

  final String id = 'hand';

  const HandArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    final ScrollController scrollController = ScrollController();

    return Container(
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '패 (${gameState.hand.length})',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: cardWidth * 0.1,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          DragTarget<Map<String, dynamic>>(
            onWillAccept: (data) => true,
            onAcceptWithDetails: (details) {
              final data = details.data;
              String sourceId = data['sourceId'] ?? '';
              int fromIndex = data['fromIndex'] ?? -1;
              DigimonCard? card = data['card'];
              final List<DigimonCard>? draggedCards = data['cards'];
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localOffset = box.globalToLocal(details.offset);

              double scrollOffset =
                  scrollController.hasClients ? scrollController.offset : 0.0;
              double adjustedX = localOffset.dx + scrollOffset;

              int toIndex = (adjustedX / cardWidth).floor();

              if (sourceId == id) {
                toIndex = toIndex.clamp(0, gameState.hand.length - 1);
                gameState.reorderHand(fromIndex, toIndex);
              } else {
                

                toIndex = toIndex.clamp(0, gameState.hand.length);
                if (draggedCards != null && draggedCards.isNotEmpty) {
                  for (int i = 0; i < draggedCards.length; i++) {
                    gameState.addCardToHandAt(draggedCards[i], toIndex + i);
                  }
                  if (data['removeCards'] != null) {
                    data['removeCards']();
                  }
                }else {
                  gameState.addCardToHandAt(card!, toIndex);
                }
                if (data['removeCard'] != null) {
                  data['removeCard']();
                }
              }
            },
            builder: (context, candidateData, rejectedData) {
              return SizedBox(
                height: cardWidth * 1.404,
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: RawScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    thickness: 8.0,
                    radius: const Radius.circular(4.0),
                    thumbColor: Colors.blueAccent,
                    trackColor: Colors.blue.shade100,
                    trackBorderColor: Colors.blue.shade300,
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: gameState.hand.length,
                      itemBuilder: (context, index) {
                        final card = gameState.hand[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Draggable<Map<String, dynamic>>(
                            data: {
                              'card': card,
                              'fromIndex': index,
                              'sourceId': id,
                              'removeCard': () {
                                gameState.removeCardFromHandAt(index);
                              },
                            },
                            feedback: ChangeNotifierProvider.value(
                              value: gameState,
                              child: Material(
                                color: Colors.transparent,
                                child: CardWidget(
                                  card: card,
                                  cardWidth: cardWidth,
                                  rest: () {},
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: CardWidget(
                                card: card,
                                cardWidth: cardWidth,
                                rest: () {},
                              ),
                            ),
                            child: CardWidget(
                              card: card,
                              cardWidth: cardWidth,
                              rest: () {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
