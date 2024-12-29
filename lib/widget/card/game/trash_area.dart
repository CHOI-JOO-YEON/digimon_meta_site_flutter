import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';

class TrashArea extends StatelessWidget {
  final double cardWidth;

  const TrashArea({super.key, required this.cardWidth});
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      children: [
        Text('트래시 (${gameState.trash.length})'),
        Container(
          width: cardWidth,
          height: cardWidth * 1.404,
          color: Colors.grey,
          child: Center(child: Text('TRASH')),
        ),
      ],
    );
  }
}
