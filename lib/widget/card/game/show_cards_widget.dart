import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class ShowCards extends StatefulWidget {
  final double cardWidth;

  const ShowCards({Key? key, required this.cardWidth}) : super(key: key);

  @override
  State<ShowCards> createState() => _ShowCardsState();
}

class _ShowCardsState extends State<ShowCards> {
  final String id = 'show';
  bool _isShow = true;

  final List<int> _selectedIndices = [];

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  int _getSelectionOrder(int index) {
    final order = _selectedIndices.indexOf(index);
    return (order == -1) ? -1 : (order + 1);
  }

  void _selectAll(int length) {
    setState(() {
      _selectedIndices.clear();
      _selectedIndices.addAll(List.generate(length, (i) => i));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  void _sendSelectedToDeckTop(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    final selectedCards = _selectedIndices.map((idx) => (
    card: gameState.shows[idx],
    fromIndex: idx
    )).toList();

    final reversedIdx = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in reversedIdx) {
      gameState.removeCardFromShowsAt(idx);
    }

    for (int i = selectedCards.length - 1; i >= 0; i--) {
      final card = selectedCards[i].card;
      final fromIndex = selectedCards[i].fromIndex;
      gameState.addCardToDeckTop(card, id, fromIndex);
    }

    _clearSelection();
  }

  void _sendSelectedToDeckBottom(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    final selectedCards = _selectedIndices.map((idx) => (
    card: gameState.shows[idx],
    fromIndex: idx
    )).toList();

    final reversedIdx = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in reversedIdx) {
      gameState.removeCardFromShowsAt(idx);
    }

    for (final tuple in selectedCards) {
      final card = tuple.card;
      final fromIndex = tuple.fromIndex;
      gameState.addCardToDeckBottom(card, id, fromIndex);
    }
    _clearSelection();
  }

  void _sendSelectedToTrash(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    final selectedCards = _selectedIndices.map((idx) => (
    card: gameState.shows[idx],
    fromIndex: idx
    )).toList();

    final reversedIdx = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in reversedIdx) {
      gameState.removeCardFromShowsAt(idx);
    }

    for (final tuple in selectedCards) {
      final card = tuple.card;
      final fromIndex = tuple.fromIndex;
      gameState.addCardToTrash(card, id, fromIndex);
    }

    _clearSelection();
  }

  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final scrollController = ScrollController();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: widget.cardWidth * 0.2,
              onPressed: () {
                setState(() {
                  _isShow = !_isShow;
                });
              },
              icon: const Icon(Icons.remove_red_eye_outlined),
            ),
          ],
        ),

        if (_isShow)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(widget.cardWidth * 0.1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _sendSelectedToDeckBottom(gameState),
                      child: const Text('덱 아래로 보내기'),
                    ),
                    TextButton(
                      onPressed: () => _sendSelectedToDeckTop(gameState),
                      child: const Text('덱 위로 보내기'),
                    ),
                    TextButton(
                      onPressed: () => _sendSelectedToTrash(gameState),
                      child: const Text('트래시로 보내기'),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () => _selectAll(gameState.shows.length),
                      child: const Text('모두 선택'),
                    ),
                    TextButton(
                      onPressed: _clearSelection,
                      child: const Text('모두 선택 해제'),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.all(widget.cardWidth * 0.1),
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAccept: (data) => true,
                    onAcceptWithDetails: (details) {
                      final data = details.data;
                      final sourceId = data['sourceId'] as String? ?? '';
                      final fromIndex = data['fromIndex'] as int? ?? -1;
                      final card = data['card'] as DigimonCard?;
                      final draggedCards =
                      data['cards'] == null
                          ? []
                          : data['cards'] as List<DigimonCard>;

                      final renderBox = context.findRenderObject() as RenderBox;
                      final localOffset = renderBox.globalToLocal(details.offset);
                      final scrollOffset =
                      scrollController.hasClients ? scrollController.offset : 0.0;
                      final adjustedX = localOffset.dx + scrollOffset;

                      int toIndex = (adjustedX / widget.cardWidth).floor();

                      if (toIndex < fromIndex) {
                        toIndex =
                            ((adjustedX + widget.cardWidth) / widget.cardWidth)
                                .floor();
                      }

                      if (sourceId == id) {
                        toIndex = toIndex.clamp(0, gameState.shows.length - 1);
                        gameState.reorderShow(fromIndex, toIndex);
                        return;
                      }

                      toIndex = toIndex.clamp(0, gameState.shows.length);
                      if (draggedCards.isNotEmpty) {
                        for (var i = draggedCards.length - 1; i >= 0; i--) {
                          gameState.addCardToShowsAt(
                              draggedCards[i], toIndex++, sourceId, i);
                        }
                        if (data['removeCards'] != null) {
                          data['removeCards']();
                        }
                      } else if (card != null) {
                        gameState.addCardToShowsAt(
                            card, toIndex, sourceId, fromIndex);
                        if (data['removeCard'] != null) {
                          data['removeCard']();
                        }
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return SizedBox(
                        height: widget.cardWidth * 1.404 +
                            widget.cardWidth * 0.3,
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(),
                          child: RawScrollbar(
                            controller: scrollController,
                            thumbVisibility: true,
                            thickness: 8.0,
                            radius: const Radius.circular(4.0),
                            thumbColor: Colors.black,
                            trackColor: Colors.blue.shade100,
                            trackBorderColor: Colors.blue.shade300,
                            child: ListView.builder(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: gameState.shows.length,
                              itemBuilder: (context, index) {
                                final card = gameState.shows[index];

                                final isSelected =
                                _selectedIndices.contains(index);
                                final selectionOrder = _getSelectionOrder(index);

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: widget.cardWidth * 0.02,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Draggable<Map<String, dynamic>>(
                                        data: {
                                          'card': card,
                                          'fromIndex': index,
                                          'sourceId': id,
                                          'removeCard': () {
                                            gameState.removeCardFromShowsAt(
                                                index);
                                          },
                                        },
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: _buildCardWithSelection(
                                            card: card,
                                            cardWidth: widget.cardWidth,
                                            isSelected: isSelected,
                                            selectionOrder: selectionOrder,
                                          ),
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: 0.5,
                                          child: _buildCardWithSelection(
                                            card: card,
                                            cardWidth: widget.cardWidth,
                                            isSelected: isSelected,
                                            selectionOrder: selectionOrder,
                                          ),
                                        ),
                                        child: _buildCardWithSelection(
                                          card: card,
                                          cardWidth: widget.cardWidth,
                                          isSelected: isSelected,
                                          selectionOrder: selectionOrder,
                                        ),
                                      ),

                                      SizedBox(
                                        height: widget.cardWidth * 0.2,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                _toggleSelection(index);
                                              },
                                            ),
                                            if (isSelected)
                                              Text(
                                                '$selectionOrder',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCardWithSelection({
    required DigimonCard card,
    required double cardWidth,
    required bool isSelected,
    required int selectionOrder,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      border: Border.all(
        color: isSelected ? Colors.blue : Colors.transparent,
        width: cardWidth * 0.02,
      ),
      borderRadius: BorderRadius.circular(cardWidth * 0.07),
    );

    return Container(
      width: cardWidth * 1.04,
      decoration: decoration,
      child: Stack(
        children: [
          CardWidget(
            card: card,
            cardWidth: cardWidth,
            rest: () {},
          ),

          if (isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '$selectionOrder',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
