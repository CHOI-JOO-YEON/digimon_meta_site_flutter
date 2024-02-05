import 'package:flutter/material.dart';

import '../../model/card.dart';

class DeckStatBar extends StatelessWidget {
  final DigimonCard card;
  DeckStatBar({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 레벨 바를 표시하는 로직
    List<Widget> levelIndicators = [];
    for (int i = 2; i <= 7; i++) {
      levelIndicators.add(
        Expanded(
          child: Container(
            height: 24,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: card.lv != null && card.lv! >= i ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '0',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: levelIndicators,
      ),
    );
  }
}