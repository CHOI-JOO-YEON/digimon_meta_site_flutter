import 'dart:ui';
import 'package:digimon_meta_site_flutter/widget/card/game/draggable_digimon_list_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/game/trash_show_cards_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'draggable_card_widget.dart';

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
    
    MoveCard move = MoveCard(fromId: 'show', fromStartIndex: 0, fromEndIndex: 0,);
    move.toId = 'deck';
    int toIndex = gameState.mainDeck.length;
    for(var i in _selectedIndices.reversed) {
      move.moveSet.add(MoveIndex(toIndex++, i));
    }
    _clearSelection();
    gameState.moveOrderedCards(move, true);
  }

  void _sendSelectedToDeckBottom(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    MoveCard move = MoveCard(fromId: 'show', fromStartIndex: 0, fromEndIndex: 0,);
    move.toId = 'deck';
    int toIndex = 0;
    for(var i in _selectedIndices.reversed) {
      move.moveSet.add(MoveIndex(toIndex++, i));
    }
    _clearSelection();
    gameState.moveOrderedCards(move, true);
  }

  void _sendSelectedToTrash(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    MoveCard move = MoveCard(fromId: 'show', fromStartIndex: 0, fromEndIndex: 0,);
    move.toId = 'trash';
    int toIndex = 0;
    for(var i in _selectedIndices) {
      move.moveSet.add(MoveIndex(toIndex++, i));
    }
    _clearSelection();
    gameState.moveOrderedCards(move, true);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    double resizingCardWidth = widget.cardWidth * 0.85;
    return Column(
      children: [
        SizedBox(
          height: widget.cardWidth * 2.7,
          child: gameState.isShowDialog()
              ? Column(
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
                          borderRadius:
                              BorderRadius.circular(widget.cardWidth * 0.1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      _sendSelectedToDeckBottom(gameState),
                                  child: const Text('덱 아래로 보내기'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _sendSelectedToDeckTop(gameState),
                                  child: const Text('덱 위로 보내기'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _sendSelectedToTrash(gameState),
                                  child: const Text('트래시로 보내기'),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      _selectAll(gameState.shows.length),
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
                              child: DraggableDigimonListWidget(
                                id: id,
                                cardWidth: resizingCardWidth,
                                height: resizingCardWidth * 2,
                                children: gameState.shows
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  DigimonCard card = entry.value;
                                  final isSelected =
                                      _selectedIndices.contains(index);
                                  final selectionOrder =
                                      _getSelectionOrder(index);

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: widget.cardWidth * 0.02,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Draggable<MoveCard>(
                                          data: MoveCard(
                                              fromId: id,
                                              fromStartIndex: index,
                                              fromEndIndex: index),
                                          feedback:
                                              ChangeNotifierProvider.value(
                                            value: gameState,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: _buildCardWithSelection(
                                                card: card,
                                                cardWidth: resizingCardWidth,
                                                isSelected: isSelected,
                                                selectionOrder: selectionOrder,
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.5,
                                            child: CardWidget(
                                              card: card,
                                              cardWidth: resizingCardWidth,
                                              rest: () {},
                                            ),
                                          ),
                                          child: CardWidget(
                                            card: card,
                                            cardWidth: resizingCardWidth,
                                            rest: () {},
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
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : Container(),
        ),
        SizedBox(
          height: widget.cardWidth * 0.1,
        ),
        if (gameState.isShowTrash)
          TrashShowCardsWidget(
            cardWidth: widget.cardWidth,
          )
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
