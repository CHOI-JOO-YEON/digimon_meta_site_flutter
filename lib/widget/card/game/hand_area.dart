import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class HandArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      children: [
        Text('패 (${gameState.hand.length})'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: gameState.hand
                .map((card) => Draggable<DigimonCard>(
                      data: card,
                      feedback: Material(
                        child: CardWidget(card: card),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: CardWidget(card: card),
                      ),
                      child: CardWidget(card: card),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
