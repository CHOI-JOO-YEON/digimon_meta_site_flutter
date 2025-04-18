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
  final Function(DigimonCard newCard, int toIndex, int fromIndex, String from)
      onAddCard;
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
  bool isDragging = false;
  double height = 0;

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
    double cardHeight = widget.cardWidth * 1.404;
    double cardSpacing = cardHeight * 0.16;
    final gameState = Provider.of<GameState>(context);

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) {

        final data = details.data;
        final sourceId = data['sourceId'] as String? ?? '';
        final fromIndex = data['fromIndex'] as int? ?? -1;
        final draggedCards =
            data['cards'] is List ? data['cards'].cast<DigimonCard>() : [];
        final singleCard = data['card'] as DigimonCard?;

        final RenderBox box = context.findRenderObject() as RenderBox;
        final double scrollOffset = _scrollController.offset;

        final double localY = box.globalToLocal(details.offset).dy;
        final double effectiveY = localY + scrollOffset;

        double a = height - (effectiveY + cardHeight);
        int toIndex = ((a + cardSpacing) / cardSpacing).floor();
        toIndex = toIndex.clamp(0, widget.digimonStack.length);

        if (draggedCards.isNotEmpty) {
          if (sourceId == widget.id) {
          } else {
            for (int i = 0; i < draggedCards.length; i++) {
              widget.onAddCard(draggedCards[i], toIndex + i, 0, sourceId);
            }
            if (data['removeCards'] != null) {
              data['removeCards']();
            }
          }
        } else if (singleCard != null) {
          if (sourceId == widget.id) {
            toIndex--;
            toIndex = toIndex.clamp(0, widget.digimonStack.length - 1);
            if (fromIndex != -1 &&
                fromIndex != toIndex &&
                toIndex < widget.digimonStack.length) {
              widget.onReorder(fromIndex, toIndex);
            }
          } else {
            widget.onAddCard(singleCard, toIndex, fromIndex, sourceId);

            if (data['removeCard'] != null) {
              data['removeCard']();
            }
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double stackHeight =
                cardHeight + (cardSpacing * (widget.digimonStack.length - 1));
            height = stackHeight.clamp(constraints.maxHeight, double.infinity);

            return SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                height: height,
                child: Opacity(
                  opacity: isDragging ? 0.5 : 1.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ...widget.digimonStack.asMap().entries.map((entry) {
                        int index = entry.key;
                        DigimonCard card = entry.value;

                        return Positioned(
                          bottom: index * cardSpacing,
                          child: Draggable<Map<String, dynamic>>(
                            data: {
                              'fromIndex': index,
                              'card': card,
                              'sourceId': widget.id,
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
                              angle: widget.isRotate(index) ? -pi / 8 : 0.0,
                              child: CardWidget(
                                card: card,
                                cardWidth: widget.cardWidth,
                                rest: () => triggerRest(index),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (widget.digimonStack.isNotEmpty)
                        Positioned(
                          bottom: cardHeight +
                              cardSpacing * (widget.digimonStack.length - 2),
                          left: 0,
                          child: Draggable<Map<String, dynamic>>(
                            data: {
                              'id': widget.id,
                              'cards': widget.digimonStack,
                              'sourceId': widget.id,
                              'removeCards': () {
                                for (int i = widget.digimonStack.length - 1;
                                    i >= 0;
                                    i--) {
                                  widget.onLeave(i);
                                }
                              },
                            },
                            feedback: ChangeNotifierProvider.value(
                              value: gameState,
                              child: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: widget.cardWidth,
                                  height: cardHeight +
                                      cardSpacing *
                                          (widget.digimonStack.length - 1),
                                  child: Stack(
                                    children: widget.digimonStack
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      DigimonCard card = entry.value;
                                      return Positioned(
                                        bottom: index * cardSpacing,
                                        left: 0,
                                        child: CardWidget(
                                          card: card,
                                          cardWidth: widget.cardWidth,
                                          rest: () {},
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Container(),
                            onDragStarted: () {
                              setState(() {
                                isDragging = true;
                              });
                            },
                            onDragEnd: (details) {
                              setState(() {
                                isDragging = false;
                              });
                            },
                            onDragCompleted: () {
                              setState(() {
                                isDragging = false;
                              });
                            },
                            child: Icon(
                              Icons.radio_button_on,
                              color: Colors.blue,
                              size: widget.cardWidth * 0.25,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
