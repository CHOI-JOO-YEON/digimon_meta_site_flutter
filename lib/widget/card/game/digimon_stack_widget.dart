import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/card.dart';
import 'draggable_card_widget.dart';

class DigimonStackWidget extends StatelessWidget {
  final List<DigimonCard> digimonStack;
  final Function(int fromIndex, int toIndex) onReorder;
  final Function(DigimonCard newCard, int toIndex) onAddCard;

  DigimonStackWidget({
    required this.digimonStack,
    required this.onReorder,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    // 카드 간 간격
    double cardSpacing = 20.0;
    double stackHeight = (digimonStack.length * cardSpacing) + 100; // 적당한 높이 설정

    return DragTarget<Object>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        final data = details.data;
        print(data.runtimeType);

        if (data is DigimonCard) {
          // DigimonStack에 없는 새 카드가 드롭된 경우
          print('1');
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset localOffset = box.globalToLocal(details.offset);
          int toIndex = (localOffset.dy / cardSpacing).floor();
          toIndex = toIndex.clamp(0, digimonStack.length);

          onAddCard(data , toIndex);
        } else  {
          // 기존 DigimonStack의 카드가 드래그된 경우
          Map<String, dynamic> map = data as Map<String, dynamic>;
          print('2');
          int fromIndex = map['fromIndex']!;
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset localOffset = box.globalToLocal(details.offset);
          int toIndex = (localOffset.dy / cardSpacing).floor();
          toIndex = toIndex.clamp(0, digimonStack.length - 1);

          if (fromIndex != toIndex) {
            onReorder(fromIndex, toIndex);
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          height: stackHeight, // Stack의 기본 크기 설정
          child: Stack(
            clipBehavior: Clip.none,
            children: digimonStack.asMap().entries.toList().reversed.map((entry){
              int index = entry.key;
              DigimonCard card = entry.value;

              return Positioned(
                top: index * cardSpacing,
                child: Draggable<Map<String, dynamic>>(
                  data: {'fromIndex': index},
                  feedback: Material(
                    elevation: 5,
                    child: CardWidget(card: card),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: CardWidget(card: card),
                  ),
                  child: CardWidget(card: card),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
