import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';
import 'digimon_stack_widget.dart';

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
    final gameState = Provider.of<GameState>(context);
    return ChangeNotifierProvider.value(
      value: fieldZone,
      child: Consumer<FieldZone>(
        builder: (context, fieldZone, child) {
          return Container(
            padding: EdgeInsets.all(cardWidth * 0.05),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(cardWidth * 0.1)
            ),
            child: DigimonStackWidget(
              digimonStack: fieldZone.stack,
              onReorder: (fromIndex, toIndex) {
                fieldZone.reorderStack(fromIndex, toIndex, gameState);
              },
              onAddCard: (card, toIndex, fromIndex, from) {
                fieldZone.addCardToStackAt(card, toIndex, fromIndex, from, gameState);
              },
              onLeave: (fromIndex) {
                fieldZone.removeCardToStackAt(fromIndex);
              },
              id: fieldZone.key,
              cardWidth: cardWidth * 0.85,
              triggerRest: (index) {
                if (!isRaising) {
                  fieldZone.rotateIndex(index);
                }
              },
              isRotate: fieldZone.isRotate,
            ),
          );
        },
      ),
    );
  }
}
