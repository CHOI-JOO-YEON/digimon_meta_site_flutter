import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';
import 'digimon_stack_widget.dart';

class FieldZoneWidget extends StatelessWidget {
  final FieldZone fieldZone;

  FieldZoneWidget({required this.fieldZone});

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
                  digimonStack: fieldZone.digimonStack,
                  onReorder: (fromIndex, toIndex) {
                    fieldZone.reorderDigimonStack(fromIndex, toIndex);
                  },
                  onAddCard: (card, toIndex){
                    fieldZone.addDigimonToIndex(card, toIndex);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
