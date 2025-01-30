import 'package:digimon_meta_site_flutter/widget/card/game/card_back_widget.dart';
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
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => raisingZone.hatchEgg(gameState),
                    child: CardBackWidget(
                      width: cardWidth,
                      text: '디지타마',
                      count: gameState.digitamaDeck.length
                    ),
                  )),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(cardWidth * 0.025),
                child: FieldZoneWidget(
                  fieldZone: raisingZone.fieldZone,
                  cardWidth: cardWidth * 0.85,
                  isRaising: true,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
