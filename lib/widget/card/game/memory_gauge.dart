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
    
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
        // 사용 가능한 너비 계산
        double availableWidth = constraints.maxWidth;
        
        // 화면 크기에 따른 반응형 계산
        double screenWidth = MediaQuery.of(context).size.width;
        
        // 버튼 크기 계산 (화면 크기에 따라 반응형)
        double buttonSize;
        if (screenWidth < 1200) {
          // 중간 화면
          buttonSize = (screenWidth * 0.035).clamp(25.0, 45.0);
        } else {
          // 큰 화면
          buttonSize = (screenWidth * 0.03).clamp(30.0, 50.0);
        }
        
        // 한 줄에 21개 버튼이 들어갈 수 있는지 계산
        double totalButtonWidth = (buttonSize + 2) * 21; // 버튼 크기 + 마진
        bool useTwoRows = totalButtonWidth > availableWidth;
        
        Widget createMemoryButton(int value) {
          bool isSelected = value == gameState.memory;
          
          Color bgColor;
          if (isSelected) {
            bgColor = const Color.fromRGBO(168, 230, 209, 1); // 원래 색상
          } else {
            bgColor = value == 0
                ? Colors.grey[300]!
                : (value < 0 ? Colors.white : Colors.blueAccent);
          }
          
          return Container(
            margin: EdgeInsets.all(1.0),
            child: GestureDetector(
              onTap: () {
                gameState.updateMemory(value, true);
              },
              child: Container(
                height: buttonSize,
                width: buttonSize,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle, // 원형으로 변경
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey[400]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    value.abs().toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: (buttonSize * 0.3).clamp(10.0, gameState.titleWidth(widget.cardWidth)), 
                        fontWeight: FontWeight.bold, 
                        color: value < 0 ? Colors.black : Colors.white), // 원래 색상
                  ),
                ),
              ),
            ),
          );
        }
        
        // 메모리 게이지 높이 계산
        double gaugeHeight = useTwoRows ? 
          (buttonSize * 2) + 12 : // 두 줄 + 간격 + 마진
          buttonSize + 8; // 한 줄 + 마진
        
        return SizedBox(
          height: gaugeHeight,
          child: useTwoRows ?
            // 두 줄로 표시
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 첫 번째 줄: -10부터 0까지 (11개)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(11, (index) {
                    int value = -10 + index; // -10, -9, ..., -1, 0
                    return createMemoryButton(value);
                  }),
                ),
                SizedBox(height: 4),
                // 두 번째 줄: 1부터 +10까지 (10개)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(10, (index) {
                    int value = 1 + index; // 1, 2, ..., 10
                    return createMemoryButton(value);
                  }),
                ),
              ],
            ) :
            // 한 줄로 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(21, (index) {
                int value = index - 10; // -10부터 +10까지
                return createMemoryButton(value);
              }),
            ),
        );
      },
      ),
    );
  }
}
