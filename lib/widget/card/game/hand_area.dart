import 'dart:ui';

import 'package:digimon_meta_site_flutter/widget/card/game/draggable_digimon_list_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class HandArea extends StatelessWidget {
  final double cardWidth;

  final String id = 'hand';

  const HandArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final double resizingCardWidth = cardWidth * 0.85;
    final gameState = Provider.of<GameState>(context);
    
    // 카드 실제 높이 계산
    final double cardHeight = resizingCardWidth * 1.404;
    final double textHeight = gameState.textWidth(cardWidth) * 2; // 텍스트 높이 추정
    final double padding = cardWidth * 0.2; // 상하 패딩
    final double totalHeight = cardHeight + textHeight + padding;
    
    return SizedBox(
      height: totalHeight, // 카드 높이 기준으로 제한
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(cardWidth * 0.1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('패 (${gameState.hand.length})',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: gameState.textWidth(cardWidth))),
            Expanded(
              child: DraggableDigimonListWidget(
                id: id,
                cardWidth: resizingCardWidth,
                height: cardHeight,
                children: gameState.hand.asMap().entries.map((entry) {
              int index = entry.key;
              DigimonCard card = entry.value;

              return Draggable<MoveCard>(
                data: MoveCard(
                    fromId: id,
                    fromStartIndex: index,
                    fromEndIndex: index,
                    restStatus: false),
                feedback: ChangeNotifierProvider.value(
                  value: gameState,
                  child: Material(
                    color: Colors.transparent,
                    child: CardWidget(
                      card: card,
                      cardWidth: resizingCardWidth,
                      rest: () {},
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: CardWidget(
                    card: card,
                    cardWidth: resizingCardWidth,
                    rest: () {},
                  ),
                ),
                child: CardWidget(
                  card: card,
                  cardWidth: resizingCardWidth,
                  rest: () {},
                ),
              );
            }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
