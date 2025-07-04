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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // 사용 가능한 너비 계산
        double availableWidth = constraints.maxWidth;
        
        // 각 메모리 버튼의 크기 계산 (21개가 들어갈 수 있도록)
        double maxButtonWidth = availableWidth / 21 * 0.9; // 90%만 사용해서 여백 확보
        double buttonSize = (widget.cardWidth * 0.45).clamp(20.0, maxButtonWidth);
        
        // 총 필요한 너비 계산
        double totalRequiredWidth = buttonSize * 21;
        bool needsScroll = totalRequiredWidth > availableWidth;
        
        Widget memoryButtons = Row(
          mainAxisAlignment: needsScroll ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
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
        
            return Container(
              margin: needsScroll ? EdgeInsets.symmetric(horizontal: 2) : EdgeInsets.zero,
              child: GestureDetector(
                onTap: () {
                  gameState.updateMemory(value, true);
                },
                child: Container(
                  height: buttonSize,
                  width: buttonSize,
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
                          fontSize: (buttonSize * 0.3).clamp(10.0, gameState.titleWidth(widget.cardWidth)), 
                          fontWeight: FontWeight.bold, 
                          color: value < 0 ? Colors.black : Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
        
        if (needsScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: memoryButtons,
          );
        } else {
          return memoryButtons;
        }
      },
    );
  }
}
