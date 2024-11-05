import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'digimon_stack_widget.dart';
import 'draggable_card_widget.dart';

class RaisingZoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final raisingZone = gameState.raisingZone;

    return Column(
      children: [
        Text('육성 존'),
        DragTarget<DigimonCard>(
          onWillAccept: (data) => true,
          onAccept: (card) {
            raisingZone.evolveDigimon(card);
            gameState.removeCardFromOrigin(card);
          },
          builder: (context, candidateData, rejectedData) {
            return Row(
              children: [
                if (raisingZone.eggCard != null)
                  CardWidget(card: raisingZone.eggCard!),
                DigimonStackWidget(
                  digimonStack: raisingZone.digimonStack,
                  onReorder: (fromIndex, toIndex) {
                    raisingZone.reorderDigimonStack(fromIndex, toIndex);
                  },
                  onAddCard: (card, toIndex) {
                    raisingZone.addDigimonToIndex(card, toIndex);
                  },
                ),
              ],
            );
          },
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                raisingZone.hatchEgg(gameState.digitamaDeck);
              },
              child: Text('부화'),
            ),
            ElevatedButton(
              onPressed: () {
                final digimon = raisingZone.moveToField();
                if (digimon != null) {
                  gameState.fieldZones[0].addDigimon(digimon);
                }
              },
              child: Text('필드로 이동'),
            ),
          ],
        ),
      ],
    );
  }
}
