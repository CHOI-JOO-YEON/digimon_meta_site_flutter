import 'package:digimon_meta_site_flutter/widget/card/game/card_back_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/game/draggable_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';

class DeckArea extends StatelessWidget {
  final double cardWidth;

  const DeckArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => gameState.drawCard(),
          child: CardBackWidget(
            width: cardWidth,
            text: '덱',
            count: gameState.mainDeck.length,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2.0, // 버튼 간 가로 간격
          runSpacing: 2.0, // 줄 간 세로 간격
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: gameState.iconWidth(cardWidth),
                maxWidth: cardWidth * 0.8, // 최대 너비 제한
              ),
              child: IconButton(
                onPressed: () => gameState.showCard(),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.search,
                  size: gameState.iconWidth(cardWidth),
                ),
                tooltip: '오픈',
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: gameState.iconWidth(cardWidth),
                maxWidth: cardWidth * 0.8, // 최대 너비 제한
              ),
              child: IconButton(
                onPressed: () => gameState.toggleShowDialog(),
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.visibility,
                  size: gameState.iconWidth(cardWidth),
                ),
                tooltip: '오픈 창 보기',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
