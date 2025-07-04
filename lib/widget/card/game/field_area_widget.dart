import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../state/game_state.dart';
import 'field_zone_widget.dart';

class FieldArea extends StatelessWidget {
  final double cardWidth;

  const FieldArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    double resizingWidth = cardWidth * 0.85;
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Column(
          children: [
            Text('필드',
                style: TextStyle(fontSize: gameState.textWidth(cardWidth))),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 0.35,
                          crossAxisSpacing: resizingWidth * 0.05),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          key: ValueKey('field_zone_$index'),
                          fieldZone: gameState.fieldZones["field$index"]!,
                          cardWidth: resizingWidth,
                          isRaising: false,
                        );
                      },
                    ),
                    SizedBox(
                      height: resizingWidth * 0.05,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 0.712,
                          crossAxisSpacing: resizingWidth * 0.05),
                      itemCount: gameState.fieldZones.length - 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          key: ValueKey('field_zone_${index + 8}'),
                          fieldZone: gameState.fieldZones["field${index + 8}"]!,
                          cardWidth: resizingWidth,
                          isRaising: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     gameState.addFieldZone(16);
            //   },
            //   child: const Text('필드 존 추가'),
            // ),
          ],
        );
      },
    );
  }
}

class ResponsiveFieldArea extends StatelessWidget {
  final double cardWidth;
  final int fieldColumns;

  const ResponsiveFieldArea({
    super.key, 
    required this.cardWidth,
    required this.fieldColumns,
  });

  @override
  Widget build(BuildContext context) {
    // 이미 게임 플레이그라운드에서 적절한 크기로 조정되어 전달됨
    double resizingWidth = cardWidth * 0.85;
    
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        // 전체 필드 존 수 계산
        final totalFields = gameState.fieldZones.length;
        final firstRowCount = fieldColumns.clamp(1, totalFields);
        final secondRowCount = (totalFields - firstRowCount).clamp(0, fieldColumns);
        
        // 필드 영역의 실제 너비 계산 (카드 크기에 맞춤)
        double fieldWidth = (resizingWidth + (resizingWidth * 0.05)) * fieldColumns;
        
        return Column(
          children: [
            Text('필드',
                style: TextStyle(fontSize: gameState.textWidth(cardWidth))),
            Expanded(
              child: Center( // 중앙 정렬
                child: SizedBox(
                  width: fieldWidth, // 필드 영역 너비 제한
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 첫 번째 행
                        if (firstRowCount > 0)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: firstRowCount,
                                childAspectRatio: 0.35,
                                crossAxisSpacing: resizingWidth * 0.05),
                            itemCount: firstRowCount,
                            itemBuilder: (context, index) {
                              return FieldZoneWidget(
                                key: ValueKey('field_zone_$index'),
                                fieldZone: gameState.fieldZones["field$index"]!,
                                cardWidth: resizingWidth,
                                isRaising: false,
                              );
                            },
                          ),
                        if (firstRowCount > 0 && secondRowCount > 0)
                          SizedBox(
                            height: resizingWidth * 0.05,
                          ),
                        // 두 번째 행 (현재 컬럼 수에 맞춰서만 표시)
                        if (secondRowCount > 0)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: fieldColumns, // 동일한 컬럼 수 사용
                                childAspectRatio: 0.712,
                                crossAxisSpacing: resizingWidth * 0.05),
                            itemCount: fieldColumns, // 컬럼 수만큼만 표시
                            itemBuilder: (context, index) {
                              int fieldIndex = index + firstRowCount;
                              // 해당 인덱스의 필드가 존재하는지 확인
                              if (fieldIndex < totalFields) {
                                return FieldZoneWidget(
                                  key: ValueKey('field_zone_$fieldIndex'),
                                  fieldZone: gameState.fieldZones["field$fieldIndex"]!,
                                  cardWidth: resizingWidth,
                                  isRaising: false,
                                );
                              } else {
                                // 빈 공간
                                return Container();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
