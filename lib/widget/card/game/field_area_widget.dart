import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../state/game_state.dart';
import 'field_zone_widget.dart';

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
        return LayoutBuilder(
          builder: (context, constraints) {
            double availableWidth = constraints.maxWidth;
            double availableHeight = constraints.maxHeight;
            
            // 전체 필드 존 수 계산
            final totalFields = gameState.fieldZones.length;
            final firstRowCount = fieldColumns.clamp(1, totalFields);
            
            // 작은 필드 줄 수 계산 (컬럼 수에 따라 조정)
            int smallFieldRows;
            if (fieldColumns == 9) {
              smallFieldRows = 1; // 9개 컬럼일 때: 1줄
            } else if (fieldColumns == 7) {
              smallFieldRows = 2; // 7개 컬럼일 때: 2줄
            } else { // fieldColumns == 5
              smallFieldRows = 3; // 5개 컬럼일 때: 3줄
            }
            
            // 총 작은 필드 개수 계산
            final totalSmallFields = fieldColumns * smallFieldRows;
            final actualSmallFields = (totalFields - firstRowCount).clamp(0, totalSmallFields);
            
            // 필드 영역의 실제 너비를 전체 사용 가능 너비로 설정
            double fieldWidth = availableWidth;
            
            // 텍스트 높이 계산
            double textHeight = gameState.textWidth(cardWidth) * 1.5;
            
            // 작은 필드의 고정 높이 (카드 비율 0.712 기준)
            double smallFieldCardWidth = (fieldWidth - (resizingWidth * 0.06 * (fieldColumns - 1))) / fieldColumns;
            double smallFieldHeight = smallFieldCardWidth / 0.712;
            
            // 여백 계산
            double spacingBetweenRows = resizingWidth * 0.06;
            double smallFieldRowsSpacing = resizingWidth * 0.05 * (smallFieldRows - 1);
            
            // 큰 필드에 사용할 수 있는 높이 계산
            double usedHeight = textHeight + smallFieldHeight + spacingBetweenRows + smallFieldRowsSpacing;
            double remainingHeight = availableHeight - usedHeight;
            
            // 큰 필드의 카드 너비 계산
            double bigFieldCardWidth = (fieldWidth - (resizingWidth * 0.06 * (firstRowCount - 1))) / firstRowCount;
            
            // 큰 필드의 aspect ratio 계산 (높이를 남은 공간에 맞춤)
            double bigFieldAspectRatio = bigFieldCardWidth / remainingHeight;

            return Column(
              children: [
                Text('필드',
                    style: TextStyle(fontSize: gameState.textWidth(cardWidth))),
                Expanded(
                  child: SizedBox(
                    width: fieldWidth, // 전체 너비 사용
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // 첫 번째 행 (긴 필드) - 남은 공간을 모두 사용
                          if (firstRowCount > 0)
                            SizedBox(
                              height: remainingHeight,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: firstRowCount,
                                    childAspectRatio: bigFieldAspectRatio,
                                    crossAxisSpacing: resizingWidth * 0.06),
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
                            ),
                          if (firstRowCount > 0 && actualSmallFields > 0)
                            SizedBox(
                              height: spacingBetweenRows,
                            ),
                          // 작은 필드들 (여러 줄) - 고정 크기
                          ...List.generate(smallFieldRows, (rowIndex) {
                            final startIndex = firstRowCount + (rowIndex * fieldColumns);
                            final endIndex = (startIndex + fieldColumns).clamp(0, totalFields);
                            final rowItemCount = endIndex - startIndex;
                            
                            if (rowItemCount <= 0) return Container();
                            
                            return Column(
                              children: [
                                if (rowIndex > 0) SizedBox(height: resizingWidth * 0.05),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: fieldColumns,
                                      childAspectRatio: 0.712, // 작은 필드는 고정 비율
                                      crossAxisSpacing: resizingWidth * 0.06),
                                  itemCount: fieldColumns,
                                  itemBuilder: (context, index) {
                                    int fieldIndex = startIndex + index;
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
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
