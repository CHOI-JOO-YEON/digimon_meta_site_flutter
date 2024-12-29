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
  final double cardWidth;

  const RaisingZoneWidget({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final raisingZone = gameState.raisingZone;

    return Column(
      children: [
        const Text('육성 존'),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: cardWidth,
                    height: cardWidth * 1.404,
                  )),
              Expanded(
                  child: FieldZoneWidget(
                fieldZone: raisingZone.fieldZone,
                cardWidth: cardWidth,
                isRaising: true,
              )),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            raisingZone.hatchEgg();
          },
          child: const Text('부화'),
        ),
      ],
    );
  }
}
