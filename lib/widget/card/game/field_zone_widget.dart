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
    return ChangeNotifierProvider.value(
      value: fieldZone,
      child: Consumer<FieldZone>(
        builder: (context, fieldZone, child) {
          return Padding(
            padding: EdgeInsets.all(cardWidth * 0.05),
            child: DigimonStackWidget(
              digimonStack: fieldZone.stack,
              onReorder: (fromIndex, toIndex) {
                fieldZone.reorderStack(fromIndex, toIndex);
              },
              onAddCard: (card, toIndex) {
                fieldZone.addCardToStackAt(card, toIndex);
              },
              onLeave: (fromIndex) {
                fieldZone.removeCardToStackAt(fromIndex);
              },
              id: UniqueKey().toString(),
              cardWidth: cardWidth * 0.9,
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
