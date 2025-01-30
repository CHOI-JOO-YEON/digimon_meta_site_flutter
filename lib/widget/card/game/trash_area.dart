import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';
import 'card_back_widget.dart';

class TrashArea extends StatelessWidget {
  final double cardWidth;

  const TrashArea({super.key, required this.cardWidth});
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      children: [
        GestureDetector(
          onTap: (){
            gameState.updateShowTrash(!gameState.isShowTrash);
          },
          child: CardBackWidget(width: cardWidth, text: 'TRASH', count: gameState.trash.length,)
        ),
      ],
    );
  }
}
