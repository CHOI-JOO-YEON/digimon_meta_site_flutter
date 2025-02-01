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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => gameState.showCard(),
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.search,
                size: gameState.iconWidth(cardWidth),
              ),
              tooltip: '오픈',
            )
          ],
        ),
      ],
    );
  }
}
