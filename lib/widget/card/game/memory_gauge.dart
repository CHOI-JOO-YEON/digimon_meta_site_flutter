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
        double screenHeight = MediaQuery.of(context).size.height;
        double aspectRatio = screenWidth / screenHeight;
        
        // 버튼 크기 계산 (완전 반응형)
        double buttonSize;
        
        // 화면 비율이 작은 경우 (모바일 가로화면) 자동으로 2줄 표시
        bool forceTwoRows = aspectRatio < 1.6;
        
        // 반응형 최소/최대 크기 계산 (cardWidth 기준)
        double minButtonSize = widget.cardWidth * 0.3; // 카드 너비의 30%
        double maxButtonSize;
        
        if (forceTwoRows) {
          // 2줄로 표시할 때 버튼 크기 계산 (첫 번째 줄 11개 기준)
          // 반응형 마진을 고려한 계산 (초기 추정값 사용)
          double estimatedMargin = minButtonSize * 0.04 * 2; // 양쪽 마진
          maxButtonSize = (availableWidth - (estimatedMargin * 11)) / 11;
          
          // 화면 크기에 따른 기본 버튼 크기 계산
          double baseButtonSize = availableWidth * 0.08; // 사용 가능한 너비의 8%
          buttonSize = baseButtonSize.clamp(minButtonSize, maxButtonSize);
        } else {
          // 1줄로 표시할 때 버튼 크기 계산
          // 반응형 마진을 고려한 계산 (초기 추정값 사용)
          double estimatedMargin = minButtonSize * 0.04 * 2; // 양쪽 마진
          maxButtonSize = (availableWidth - (estimatedMargin * 21)) / 21;
          
          // 화면 크기에 따른 기본 버튼 크기 계산
          double baseButtonSize = availableWidth * 0.04; // 사용 가능한 너비의 4%
          buttonSize = baseButtonSize.clamp(minButtonSize, maxButtonSize);
        }
        
        // 한 줄에 21개 버튼이 들어갈 수 있는지 계산 (실제 마진 사용)
        double buttonMargin = buttonSize * 0.04 * 2; // 양쪽 마진
        double totalButtonWidth = (buttonSize + buttonMargin) * 21;
        bool useTwoRows = forceTwoRows || totalButtonWidth > availableWidth;
        
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
            margin: EdgeInsets.all(buttonSize * 0.04), // 버튼 크기의 4%
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
                        fontSize: (buttonSize * 0.35).clamp(
                          widget.cardWidth * 0.15, // 최소 크기: 카드 너비의 15%
                          gameState.titleWidth(widget.cardWidth)
                        ), 
                        fontWeight: FontWeight.bold, 
                        color: value < 0 ? Colors.black : Colors.white), // 원래 색상
                  ),
                ),
              ),
            ),
          );
        }
        
        // 메모리 게이지 높이 계산 (반응형)
        double buttonMarginVertical = buttonSize * 0.04 * 2; // 상하 마진
        double rowGap = useTwoRows ? buttonSize * 0.1 : 0; // 줄 간격
        double gaugeHeight = useTwoRows ? 
          (buttonSize * 2) + rowGap + (buttonMarginVertical * 2) : // 두 줄 + 간격 + 마진
          buttonSize + buttonMarginVertical; // 한 줄 + 마진
        
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
                SizedBox(height: buttonSize * 0.1), // 버튼 크기의 10%
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
