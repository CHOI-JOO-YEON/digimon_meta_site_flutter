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
        Text('덱 (${gameState.mainDeck.length})'),
        ElevatedButton(
          onPressed: () {
            gameState.drawCard();
          },
          child: Text('드로우'),
        ),
        ElevatedButton(
          onPressed: () {
            gameState.drawCard();
          },
          child: Text('드로우'),
        ),
        Container(
          width: cardWidth,
          height: cardWidth * 1.404,
          color: Colors.blue,
          child: Center(child: Text('DECK')),
        ),
      ],
    );
  }
}
