import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';
import 'draggable_digimon_list_widget.dart';

class TrashShowCardsWidget extends StatelessWidget {
  final String id = 'trash';
  final double cardWidth;

  const TrashShowCardsWidget({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    double resizingCardWidth = cardWidth * 0.85;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(cardWidth * 0.1),
      ),
      child: Column(
        children: [
          Text('트래시 (${gameState.trash.length})'),
          Padding(
            padding: EdgeInsets.all(cardWidth * 0.1),
            child: DraggableDigimonListWidget(
              id: id,
              cardWidth: resizingCardWidth,
              height: resizingCardWidth * 1.404,
              children: gameState.trash.asMap().entries.map((entry) {
                int index = entry.key;
                DigimonCard card = entry.value;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardWidth * 0.02,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Draggable<MoveCard>(
                        data: MoveCard(
                            fromId: id,
                            fromStartIndex: index,
                            fromEndIndex: index),
                        feedback: Material(
                          color: Colors.transparent,
                          child: ChangeNotifierProvider.value(
                            value: gameState,
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
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
