import 'dart:ui';

import 'package:digimon_meta_site_flutter/widget/card/game/draggable_digimon_list_widget.dart';
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
    final double resizingCardWidth = cardWidth * 0.85;
    final gameState = Provider.of<GameState>(context);

    final ScrollController scrollController = ScrollController();

    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(cardWidth * 0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '패 (${gameState.hand.length})',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: cardWidth * 0.15,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
            ),
          ),
          // DragTarget<Map<String, dynamic>>(
          //   onWillAccept: (data) => true,
          //   onAcceptWithDetails: (details) {
          //     final data = details.data;
          //     final sourceId = data['sourceId'] as String? ?? '';
          //     final fromIndex = data['fromIndex'] as int? ?? -1;
          //     final card = data['card'] as DigimonCard?;
          //     final draggedCards = data['cards'] == null
          //         ? []
          //         : data['cards'] as List<DigimonCard>;
          //
          //     final renderBox = context.findRenderObject() as RenderBox;
          //     final localOffset = renderBox.globalToLocal(details.offset);
          //
          //     final scrollOffset =
          //         scrollController.hasClients ? scrollController.offset : 0.0;
          //     final adjustedX = localOffset.dx + scrollOffset;
          //
          //     int toIndex = (adjustedX / cardWidth).floor();
          //
          //     if (toIndex < fromIndex) {
          //       toIndex = ((adjustedX + cardWidth) / cardWidth).floor();
          //     }
          //
          //     if (sourceId == id) {
          //       toIndex = toIndex.clamp(0, gameState.hand.length - 1);
          //       gameState.reorderHand(fromIndex, toIndex);
          //       return;
          //     }
          //     toIndex = toIndex.clamp(0, gameState.hand.length);
          //     if (draggedCards.isNotEmpty) {
          //       for (var i = draggedCards.length - 1; i >= 0; i--) {
          //         gameState.addCardToHandAt(
          //             draggedCards[i], toIndex++, sourceId, i);
          //       }
          //       if (data['removeCards'] != null) {
          //         data['removeCards']();
          //       }
          //     } else if (card != null) {
          //       gameState.addCardToHandAt(card, toIndex, sourceId, fromIndex);
          //       if (data['removeCard'] != null) {
          //         data['removeCard']();
          //       }
          //     }
          //   },
          //   builder: (context, candidateData, rejectedData) {
          //     return SizedBox(
          //       height: cardWidth * 0.8 * 1.404,
          //       child: ScrollConfiguration(
          //         behavior: CustomScrollBehavior(),
          //         child: RawScrollbar(
          //           controller: scrollController,
          //           thumbVisibility: true,
          //           thickness: 8.0,
          //           radius: const Radius.circular(4.0),
          //           thumbColor: Colors.blueAccent,
          //           trackColor: Colors.blue.shade100,
          //           trackBorderColor: Colors.blue.shade300,
          //           child: ListView.builder(
          //             controller: scrollController,
          //             scrollDirection: Axis.horizontal,
          //             itemCount: gameState.hand.length,
          //             itemBuilder: (context, index) {
          //               final card = gameState.hand[index];
          //               return Draggable<MoveCard>(
          //                 data: MoveCard(fromId: id, fromStartIndex: index, fromEndIndex: index),
          //                 feedback: ChangeNotifierProvider.value(
          //                   value: gameState,
          //                   child: Material(
          //                     color: Colors.transparent,
          //                     child: CardWidget(
          //                       card: card,
          //                       cardWidth: cardWidth*0.85,
          //                       rest: () {},
          //                     ),
          //                   ),
          //                 ),
          //                 childWhenDragging: Opacity(
          //                   opacity: 0.5,
          //                   child: CardWidget(
          //                     card: card,
          //                     cardWidth: cardWidth*0.8,
          //                     rest: () {},
          //                   ),
          //                 ),
          //                 child: CardWidget(
          //                   card: card,
          //                   cardWidth: cardWidth * 0.8,
          //                   rest: () {},
          //                 ),
          //               );
          //             },
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          DraggableDigimonListWidget(
            id: id,
            cardWidth: resizingCardWidth,
            children: gameState.hand.asMap().entries.map((entry) {
              int index = entry.key;
              DigimonCard card = entry.value;

              return Draggable<MoveCard>(
                data: MoveCard(
                    fromId: id, fromStartIndex: index, fromEndIndex: index),
                feedback: ChangeNotifierProvider.value(
                  value: gameState,
                  child: Material(
                    color: Colors.transparent,
                    child: CardWidget(
                      card: card,
                      cardWidth: resizingCardWidth,
                      rest: () {},
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: CardWidget(
                    card: card,
                    cardWidth: resizingCardWidth,
                    rest: () {},
                  ),
                ),
                child: CardWidget(
                  card: card,
                  cardWidth: resizingCardWidth,
                  rest: () {},
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
