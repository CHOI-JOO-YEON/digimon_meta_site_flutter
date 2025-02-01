import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'card_back_widget.dart';

class CardWidget extends StatelessWidget {
  final DigimonCard card;
  final double cardWidth;
  final Function rest;

  const CardWidget(
      {super.key,
      required this.card,
      required this.cardWidth,
      required this.rest});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return SizedBox(
      width: cardWidth,
      height: cardWidth * 1.404,
      child: GestureDetector(
        onTap: () {
          if (!(card.isToken ?? false)) {
            gameState.updateSelectedCard(card);
          }
        },
        onDoubleTap: () {
          rest();
        },
        child: (card.isToken != null && card.isToken!)
            ? CardBackWidget(
                text: '토큰',
                width: cardWidth,
              )
            : Image.network(
                card.getDisplaySmallImgUrl() ?? '',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: Center(
                        child: Text(card.getDisplayName() ?? 'Unknown',
                            style: TextStyle(
                                fontSize: gameState.textWidth(cardWidth)))),
                  );
                },
              ),
      ),
    );
  }
}
