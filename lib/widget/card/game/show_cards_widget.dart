import 'dart:ui';
import 'package:digimon_meta_site_flutter/widget/card/game/draggable_digimon_list_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/game/trash_show_cards_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

    MoveCard move = MoveCard(
      fromId: 'show',
      fromStartIndex: 0,
      fromEndIndex: 0,
      restStatus: false,
    );
    move.toId = 'deck';
    int toIndex = gameState.mainDeck.length;
    for (var i in _selectedIndices.reversed) {
      move.moveSet.add(MoveIndex(toIndex++, i));
    }
    _clearSelection();
    gameState.moveOrderedCards(move, true);
  }

  void _sendSelectedToDeckBottom(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    MoveCard move = MoveCard(
      fromId: 'show',
      fromStartIndex: 0,
      fromEndIndex: 0,
      restStatus: false,
    );
    move.toId = 'deck';
    int toIndex = 0;
    for (var i in _selectedIndices.reversed) {
      move.moveSet.add(MoveIndex(toIndex++, i));
    }
    _clearSelection();
    gameState.moveOrderedCards(move, true);
  }

  void _sendSelectedToTrash(GameState gameState) {
    if (_selectedIndices.isEmpty) return;

    MoveCard move = MoveCard(
      fromId: 'show',
      fromStartIndex: 0,
      fromEndIndex: 0,
      restStatus: false,
    );
    move.toId = 'trash';
    int toIndex = 0;
    for (var i in _selectedIndices) {
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
          height: widget.cardWidth * 4,
          child: gameState.isShowDialog()
              ? Column(
                  children: [

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
                                  child: Text(
                                    '덱 아래로 보내기',
                                    style: TextStyle(
                                        fontSize: gameState
                                            .textWidth(widget.cardWidth)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _sendSelectedToDeckTop(gameState),
                                  child: Text(
                                    '덱 위로 보내기',
                                    style: TextStyle(
                                        fontSize: gameState
                                            .textWidth(widget.cardWidth)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _sendSelectedToTrash(gameState),
                                  child: Text(
                                    '트래시로 보내기',
                                    style: TextStyle(
                                        fontSize: gameState
                                            .textWidth(widget.cardWidth)),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      _selectAll(gameState.shows.length),
                                  child: Text(
                                    '모두 선택',
                                    style: TextStyle(
                                        fontSize: gameState
                                            .textWidth(widget.cardWidth)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _clearSelection,
                                  child: Text(
                                    '모두 선택 해제',
                                    style: TextStyle(
                                        fontSize: gameState
                                            .textWidth(widget.cardWidth)),
                                  ),
                                ),
                              ],
                            ),
                            DraggableDigimonListWidget(
                              id: id,
                              cardWidth: resizingCardWidth,
                              height: resizingCardWidth * 1.8,
                              children:
                                  gameState.shows.asMap().entries.map((entry) {
                                int index = entry.key;
                                DigimonCard card = entry.value;
                                final isSelected =
                                    _selectedIndices.contains(index);
                                final selectionOrder =
                                    _getSelectionOrder(index);

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Draggable<MoveCard>(
                                      data: MoveCard(
                                          fromId: id,
                                          fromStartIndex: index,
                                          fromEndIndex: index,
                                          restStatus: false),
                                      feedback: ChangeNotifierProvider.value(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ConstrainedBox(
                                            constraints:
                                                BoxConstraints.tightFor(
                                              width: gameState
                                                  .iconWidth(resizingCardWidth),
                                              height: gameState
                                                  .iconWidth(resizingCardWidth),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                _toggleSelection(index);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    resizingCardWidth * 0.02),
                                                child: Container(
                                                  width: gameState.iconWidth(
                                                          resizingCardWidth) *
                                                      0.7,
                                                  height: gameState.iconWidth(
                                                          resizingCardWidth) *
                                                      0.7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.blue
                                                          : Colors.grey,
                                                      width: 2,
                                                    ),
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.transparent,
                                                  ),
                                                  child: isSelected
                                                      ? Icon(Icons.check,
                                                          size: gameState
                                                                  .iconWidth(widget
                                                                      .cardWidth) *
                                                              0.5,
                                                          color: Colors.white)
                                                      : null,
                                                ),
                                              ),
                                            )),
                                        if (isSelected)
                                          Text(
                                            '$selectionOrder',
                                            style: TextStyle(
                                              fontSize: gameState
                                                  .textWidth(resizingCardWidth),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              : Container(),
        ),
        SizedBox(
          height: widget.cardWidth * 0.4,
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
