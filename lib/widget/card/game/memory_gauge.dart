import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/game_state.dart';

class MemoryGauge extends StatefulWidget {
  final double cardWidth;
  const MemoryGauge({super.key, required this.cardWidth});

  @override
  _MemoryGaugeState createState() => _MemoryGaugeState();
}

class _MemoryGaugeState extends State<MemoryGauge> {

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(21, (index) {
        int value = index - 10;
        bool isSelected = value == gameState.memory;
    
        Color bgColor;
        if (isSelected) {
          bgColor =
              const Color.fromRGBO(168, 230, 209, 1); // 오른쪽(나) & 0은 중립
        } else {
          bgColor = value == 0
              ? Colors.grey[300]!
              : (value < 0 ? Colors.white : Colors.blueAccent);
        }
    
        return GestureDetector(
          onTap: () {
            gameState.updateMemory(value, true);
          },
          child: Container(
            height: widget.cardWidth*0.32,
            width: widget.cardWidth*0.32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ]
            ),
            child: Center(
              child: Text(
                value.abs().toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: gameState.titleWidth(widget.cardWidth), fontWeight: FontWeight.bold, color: value < 0 ? Colors.black : Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }
}
