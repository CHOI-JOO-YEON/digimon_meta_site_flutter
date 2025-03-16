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
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    // 현재 선택된 메모리 값을 중앙에 오도록 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 스크롤 컨트롤러가 준비되었을 때만 작동
      if (_scrollController.hasClients) {
        // 아이템 크기 계산
        final containerWidth = MediaQuery.of(context).size.width;
        final totalItems = 21; // -10부터 10까지
        final itemWidth = containerWidth / 11; // 화면에 약 11개 아이템이 보이도록
        
        // 선택된 메모리 값의 위치 계산 (-10 ~ 10 중에서)
        final selectedIndex = gameState.memory + 10; // -10이 0번 인덱스, 10이 20번 인덱스
        
        // 스크롤 위치 계산: 선택된 아이템이 가운데 오도록
        final maxScroll = _scrollController.position.maxScrollExtent;
        final itemFullWidth = maxScroll / (totalItems - 11); // 스크롤 가능한 각 아이템의 실제 너비
        final targetScroll = (selectedIndex - 5) * itemFullWidth; // 5는 화면 중앙에 표시될 아이템 위치
        
        try {
          // 부드러운 스크롤
          _scrollController.animateTo(
            targetScroll.clamp(0.0, maxScroll),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
          );
        } catch (e) {
          // 스크롤 컨트롤러 오류 처리
        }
      }
    });
    
    // 스크린샷과 유사한 디자인 구현
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final itemWidth = availableWidth / 11; // 약 11개 아이템을 보이게
          
          return Container(
            height: itemWidth * 1.05, // 높이를 적절하게 조정
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(), // 부드러운 스크롤 효과
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(21, (index) {
                  int value = index - 10;
                  return _buildMemoryItem(value, gameState, itemWidth);
                }),
              ),
            ),
          );
        }
      ),
    );
  }
  
  // 메모리 아이템 위젯 - 스크린샷과 유사하게 구현
  Widget _buildMemoryItem(int value, GameState gameState, double itemWidth) {
    bool isSelected = value == gameState.memory;
    
    // 스크린샷과 유사한 색상 설정
    Color bgColor;
    Color textColor = Colors.black;
    
    if (isSelected) {
      // 선택된 메모리는 초록색 계열
      bgColor = Color(0xFFA8E6D1); // 스크린샷의 초록색에 가까운 색상
    } else if (value == 0) {
      // 0(중립)은 회색
      bgColor = Colors.grey[300]!;
    } else if (value < 0) {
      // 음수(왼쪽)은 흰색
      bgColor = Colors.white;
    } else {
      // 양수(오른쪽)은 파란색
      bgColor = Colors.blue;
      textColor = Colors.white; // 파란 배경에 흰색 텍스트로 가독성 향상
    }
    
    // 스크린샷과 유사한 원형 디자인
    return Container(
      width: itemWidth * 0.9,
      height: itemWidth * 0.9,
      margin: EdgeInsets.symmetric(horizontal: itemWidth * 0.05),
      child: GestureDetector(
        onTap: () {
          gameState.updateMemory(value, true);
        },
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                spreadRadius: 1,
                offset: Offset(0, 1),
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              value.abs().toString(),
              style: TextStyle(
                fontSize: itemWidth * 0.4,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
