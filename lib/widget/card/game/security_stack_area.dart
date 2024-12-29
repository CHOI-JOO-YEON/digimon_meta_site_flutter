import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class SecurityStackArea extends StatelessWidget {
  final double cardWidth;

  const SecurityStackArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '시큐리티 스택 (${gameState.securityStack.length})',
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: gameState.securityStack.asMap().entries.map((entry) {
                int index = entry.key;
                DigimonCard card = entry.value;
                return SecurityCardWidget(
                    card: card, index: index, cardWidth: cardWidth);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class SecurityCardWidget extends StatefulWidget {
  final DigimonCard card;
  final int index;
  final double cardWidth;

  SecurityCardWidget(
      {required this.card, required this.index, required this.cardWidth});

  @override
  _SecurityCardWidgetState createState() => _SecurityCardWidgetState();
}

class _SecurityCardWidgetState extends State<SecurityCardWidget> {
  bool isFaceUp = false;

  void flipCard() {
    setState(() {
      isFaceUp = !isFaceUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: SizedBox(
        width: widget.cardWidth * 1.404,
        height: widget.cardWidth,
        child: isFaceUp
            ? RotatedBox(
                quarterTurns: 3, // 시계 방향으로 270도 회전 (-90도)
                child: SizedBox.expand(
                  child: CardWidget(
                    card: widget.card,
                    cardWidth: widget.cardWidth,
                    rest: (){},
                  ),
                ),
              )
            : Container(
                color: Colors.blue,
                child: const Center(child: Text('BACK')),
              ),
      ),
    );
  }
}
