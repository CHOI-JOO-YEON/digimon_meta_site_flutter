import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';

class DeckArea extends StatelessWidget {
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
        Container(
          width: 60,
          height: 90,
          color: Colors.blue,
          child: Center(child: Text('DECK')),
        ),
      ],
    );
  }
}
