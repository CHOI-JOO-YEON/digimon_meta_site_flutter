import 'package:digimon_meta_site_flutter/widget/card/game/card_back_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/game/draggable_card_widget.dart';
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
      children: [
        ElevatedButton(
          onPressed: () {
            gameState.drawCard();
          },
          child: Text('드로우'),
        ),
        ElevatedButton(
          onPressed: () {
            gameState.showCard();
          },
          child: Text('카드 공개'),
        ),
        CardBackWidget(
          width: cardWidth,
          text: 'DECK',
          count: gameState.mainDeck.length,
        )
      ],
    );
  }
}
