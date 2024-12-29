import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';
import 'digimon_stack_widget.dart';

class FieldZoneWidget extends StatelessWidget {
  final FieldZone fieldZone;
  final double cardWidth;

  const FieldZoneWidget({super.key, required this.fieldZone, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: fieldZone,
      child: Consumer<FieldZone>(
        builder: (context, fieldZone, child) {
          return Container(
            color: Colors.red,
            child: Column(
              children: [
                Text('필드 존'),
                DigimonStackWidget(
                  digimonStack: fieldZone.stack,
                  onReorder: (fromIndex, toIndex) {
                    fieldZone.reorderStack(fromIndex, toIndex);
                  },
                  onAddCard: (card, toIndex){
                    fieldZone.addCardToStackAt(card, toIndex);
                  },
                  onLeave: (fromIndex){
                    fieldZone.removeCardToStackAt(fromIndex);
                  },
                  id: UniqueKey().toString(), cardWidth: cardWidth,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
