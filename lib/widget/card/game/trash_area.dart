import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'card_back_widget.dart';

class TrashArea extends StatelessWidget {
  final double cardWidth;

  const TrashArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      children: [
        DragTarget<MoveCard>(
          onWillAcceptWithDetails: (data) => true,
          onAcceptWithDetails: (details) {
            MoveCard? move = details.data;
            List<DigimonCard> cards = gameState.getCardsBySourceId(
                move.fromId, move.fromStartIndex, move.fromEndIndex);
            move.toId = 'trash';
            if (cards.isEmpty) {
              return;
            }
            move.toStartIndex = gameState.trash.length;
            gameState.moveCards(move, cards, true);
          },
          builder: (BuildContext context, List<MoveCard?> candidateData,
              List<dynamic> rejectedData) {
            return GestureDetector(
                onTap: () {
                  gameState.updateShowTrash(!gameState.isShowTrash);
                },
                child: CardBackWidget(
                  width: cardWidth,
                  text: '트래시',
                  count: gameState.trash.length,
                ));
          },
        ),
      ],
    );
  }
}
