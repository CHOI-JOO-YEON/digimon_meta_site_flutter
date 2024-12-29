import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class DigimonStackWidget extends StatefulWidget {
  final List<DigimonCard> digimonStack;
  final String id;
  final Function(int fromIndex, int toIndex) onReorder;
  final Function(DigimonCard newCard, int toIndex) onAddCard;
  final Function(int fromIndex) onLeave;
  final Function(int index) triggerRest;
  final bool Function(int index) isRotate;

  final double cardWidth;

  const DigimonStackWidget({
    super.key,
    required this.digimonStack,
    required this.onReorder,
    required this.onAddCard,
    required this.onLeave,
    required this.id,
    required this.cardWidth,
    required this.triggerRest,
    required this.isRotate,
  });

  @override
  _DigimonStackWidgetState createState() => _DigimonStackWidgetState();
}

class _DigimonStackWidgetState extends State<DigimonStackWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void triggerRest(int index) {
    widget.triggerRest(index);
  }

  @override
  Widget build(BuildContext context) {
    double cardHeight = widget.cardWidth * 1.404; // 카드의 높이 비율
    double cardSpacing = cardHeight * 0.16; // 카드 간 간격
    final gameState = Provider.of<GameState>(context);

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        final data = details.data;
        final String sourceId = data['id'] ?? '';
        final int fromIndex = data['fromIndex'] ?? -1;
        final DigimonCard card = data['card'];

        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset localOffset = box.globalToLocal(details.offset);

        final double scrollOffset =
            _scrollController.hasClients ? _scrollController.offset : 0.0;

        final Size size = box.size;
        final double rawHeight = size.height;
        final double height = rawHeight + scrollOffset;

        final double cSpacing = cardSpacing;
        final double cHeight = cardHeight;
        final int n = widget.digimonStack.length;
        final double bHeight =
            height - min(cSpacing * n, height - (cHeight - cSpacing));

        final double temp = localOffset.dy + cHeight - bHeight;

        int toIndex = (temp / cSpacing).floor();
        toIndex = n - toIndex;

        if (sourceId == widget.id) {
          if (fromIndex != -1 && fromIndex != toIndex) {
            toIndex = toIndex.clamp(0, n - 1);
            widget.onReorder(fromIndex, toIndex);
          }
        } else {
          toIndex = toIndex.clamp(0, n);
          widget.onAddCard(card, toIndex);

          if (data['removeCard'] != null) {
            data['removeCard']();
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double stackHeight =
                cardHeight + (cardSpacing * (widget.digimonStack.length - 1));
            double height =
                stackHeight.clamp(constraints.maxHeight, double.infinity);

            return SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: widget.digimonStack.asMap().entries.map((entry) {
                    int index = entry.key;
                    DigimonCard card = entry.value;

                    return Positioned(
                      bottom: index * cardSpacing,
                      child: Draggable<Map<String, dynamic>>(
                        data: {
                          'fromIndex': index,
                          'card': card,
                          'id': widget.id,
                          'removeCard': () {
                            widget.onLeave(index);
                          },
                        },
                        feedback: ChangeNotifierProvider.value(
                          value: gameState,
                          child: Material(
                            color: Colors.transparent,
                            child: CardWidget(
                              card: card,
                              cardWidth: widget.cardWidth,
                              rest: () => triggerRest(index),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: CardWidget(
                            card: card,
                            cardWidth: widget.cardWidth,
                            rest: () => triggerRest(index),
                          ),
                        ),
                        child: Transform.rotate(
                          angle: widget.isRotate(index) ? -pi / 4 : 0.0,
                          child: CardWidget(
                            card: card,
                            cardWidth: widget.cardWidth,
                            rest: () => triggerRest(index),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
