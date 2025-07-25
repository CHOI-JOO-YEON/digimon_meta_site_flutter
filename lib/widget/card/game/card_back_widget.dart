import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';

class CardBackWidget extends StatelessWidget {
  final double width;
  final int? count;
  final String? text;

  const CardBackWidget({super.key, required this.width, this.text, this.count});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border:
            Border.all(color: const Color.fromRGBO(130, 179, 162, 1), width: 3),
        color: const Color.fromRGBO(168, 230, 209, 1),
      ),
      width: width,
      height: width * 1.404,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: width / 3,
              child: Image.asset('assets/images/small_img.png')),
          if (text != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text ?? '',
                  style: TextStyle(fontSize: gameState.textWidth(width)),
                ),
                if (count != null)
                  Text(
                    '($count)',
                    style: TextStyle(fontSize: gameState.textWidth(width))),
              ],
            ),
        ],
      ),
    );
  }
}
