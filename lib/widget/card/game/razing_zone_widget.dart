import 'package:digimon_meta_site_flutter/widget/card/game/field_zone_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

    return Expanded(
      child: Column(
        children: [
          Text('육성 존'),
          Expanded(child: FieldZoneWidget(fieldZone: raisingZone.fieldZone)),
          ElevatedButton(
            onPressed: () {
              raisingZone.hatchEgg();
            },
            child: Text('부화'),
          ),
        ],
      ),
    );
  }
}
