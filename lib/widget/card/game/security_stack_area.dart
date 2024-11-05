import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class SecurityStackArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Column(
      children: [
        Text('시큐리티 스택 (${gameState.securityStack.length})'),
        Column(
          children: gameState.securityStack.asMap().entries.map((entry) {
            int index = entry.key;
            DigimonCard card = entry.value;
            return SecurityCardWidget(card: card, index: index);
          }).toList(),
        ),
      ],
    );
  }
}

class SecurityCardWidget extends StatefulWidget {
  final DigimonCard card;
  final int index;

  SecurityCardWidget({required this.card, required this.index});

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
      child: Transform.rotate(
        angle: -90 * 3.1415927 / 180, // 90도 회전
        child: Container(
          width: 60,
          height: 90,
          margin: EdgeInsets.all(2),
          child: isFaceUp
              ? CardWidget(card: widget.card)
              : Container(
                  color: Colors.blue,
                  child: Center(child: Text('BACK')),
                ),
        ),
      ),
    );
  }
}
