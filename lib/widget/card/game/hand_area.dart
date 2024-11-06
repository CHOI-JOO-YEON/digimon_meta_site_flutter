import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class HandArea extends StatelessWidget {
  final String id = 'hand';

  const HandArea({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return SizedBox(
      width: double.infinity,
      child: Container(
        color: Colors.red,
        child: Column(
          children: [
            Text('패 (${gameState.hand.length})'),
            DragTarget<Map<String, dynamic>>(
              onWillAccept: (data) => true,
              onAcceptWithDetails: (details) {
                final data = details.data;
                String sourceId = data['id'] ?? '';
                int fromIndex = data['fromIndex'] ?? -1;
                DigimonCard card = data['card'];

                RenderBox box = context.findRenderObject() as RenderBox;
                Offset localOffset = box.globalToLocal(details.offset);

                double cardWidth = 60.0;
                int toIndex = (localOffset.dx / (cardWidth)).floor();

                if (sourceId == id) {
                  toIndex = toIndex.clamp(0, gameState.hand.length - 1);
                    gameState.reorderHand(fromIndex, toIndex);
                } else {
                  toIndex = toIndex.clamp(0, gameState.hand.length);
                  gameState.addCardToHandAt(card, toIndex);
                  if (data['removeCard'] != null) {
                    data['removeCard']();
                  }
                }
              },
              onLeave: (data) {
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: Colors.red,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: gameState.hand.asMap().entries.map((entry) {
                        int index = entry.key;
                        DigimonCard card = entry.value;

                        return Draggable<Map<String, dynamic>>(
                          data: {
                            'card': card,
                            'fromIndex': index,
                            'sourceId': id,
                            'removeCard': () {
                              gameState.removeCardFromHandAt(index);
                            },
                          },
                          feedback: Material(
                            child: CardWidget(card: card),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: CardWidget(card: card),
                          ),
                          child: CardWidget(card: card),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
