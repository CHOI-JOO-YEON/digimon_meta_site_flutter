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
              // 디지타마 덱 (고정 크기)
              SizedBox(
                width: cardWidth,
                child: GestureDetector(
                  onTap: () => raisingZone.hatchEgg(gameState),
                  child: CardBackWidget(
                    width: cardWidth,
                    text: '디지타마',
                    count: gameState.digitamaDeck.length
                  ),
                ),
              ),
              SizedBox(width: cardWidth * 0.1), // 간격
              // 레이징 존 (카드 크기 참조)
              Container(
                constraints: BoxConstraints(
                  minWidth: cardWidth * 1.1, // 최소 너비를 카드 너비의 1.1배로 설정
                  minHeight: cardWidth * 1.404 * 0.8, // 최소 높이 설정 (카드 높이 기준)
                ),
                padding: EdgeInsets.all(cardWidth * 0.025),
                child: FieldZoneWidget(
                  fieldZone: raisingZone.fieldZone,
                  cardWidth: cardWidth * 0.9, // 카드 크기를 더 크게 설정
                  isRaising: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
