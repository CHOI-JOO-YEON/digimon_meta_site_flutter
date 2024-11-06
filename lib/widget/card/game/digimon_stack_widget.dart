import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/card.dart';
import 'draggable_card_widget.dart';

class DigimonStackWidget extends StatelessWidget {
  final List<DigimonCard> digimonStack;
  final String id;
  final Function(int fromIndex, int toIndex) onReorder;
  final Function(DigimonCard newCard, int toIndex) onAddCard;
  final Function(int fromIndex) onLeave;

  const DigimonStackWidget({
    super.key,
    required this.digimonStack,
    required this.onReorder,
    required this.onAddCard,
    required this.onLeave,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    double cardSpacing = 20.0;

    return Expanded(
      child: DragTarget<Map<String, dynamic>>(
        onWillAccept: (data) => true,
        onAcceptWithDetails: (details) {
          final data = details.data;
          String sourceId = data['id'] ?? '';
          int fromIndex = data['fromIndex'] ?? -1;
          DigimonCard card = data['card'];
          RenderBox box = context.findRenderObject() as RenderBox;
          Offset localOffset = box.globalToLocal(details.offset);
          int toIndex = (localOffset.dy / cardSpacing).floor();
          if (id == sourceId) {
            if (fromIndex != -1 && fromIndex != toIndex) {
              toIndex = toIndex.clamp(0, digimonStack.length - 1);
              onReorder(fromIndex, toIndex);
            }
          } else {
            toIndex = toIndex.clamp(0, digimonStack.length);
            onAddCard(card, toIndex);
            if (data['removeCard'] != null) {
              data['removeCard']();
            }
          }
        },
        onLeave: (data) {},
        builder: (context, candidateData, rejectedData) {
          return Stack(
            clipBehavior: Clip.none,
            children:
                digimonStack.asMap().entries.toList().reversed.map((entry) {
              int index = entry.key;
              DigimonCard card = entry.value;

              return Positioned(
                top: index * cardSpacing,
                child: Draggable<Map<String, dynamic>>(
                  data: {
                    'fromIndex': index,
                    'card': card,
                    'id': id,
                    'removeCard': () {
                      onLeave(index);
                    }
                  },
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
          );
        },
      ),
    );
  }
}
