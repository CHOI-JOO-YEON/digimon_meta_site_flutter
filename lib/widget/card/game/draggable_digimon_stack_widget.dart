import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';

class DraggableDigimonStackWidget extends StatefulWidget {
  final List<DigimonCard> digimonStack;
  final String id;
  final double spacing;
  final double cardHeight;
  final List<Widget> children;

  const DraggableDigimonStackWidget({
    super.key,
    required this.digimonStack,
    required this.id,
    required this.cardHeight,
    required this.spacing,
    required this.children,
  });

  @override
  State<DraggableDigimonStackWidget> createState() =>
      _DraggableDigimonStackWidgetState();
}

class _DraggableDigimonStackWidgetState
    extends State<DraggableDigimonStackWidget> {
  late ScrollController _scrollController;
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

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return DragTarget<MoveCard>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) {
        MoveCard? move = details.data;
        move.toId = widget.id;

        List<DigimonCard> cards = gameState.getCardsBySourceId(
            move.fromId, move.fromStartIndex, move.fromEndIndex);

        if (cards.isEmpty) {
          return;
        }

        final RenderBox box = context.findRenderObject() as RenderBox;
        final double scrollOffset = _scrollController.offset;
        final double localY = box.globalToLocal(details.offset).dy;
        final double effectiveY = localY + scrollOffset;

        double cardInsertHeight = height -
            (effectiveY +
                (widget.cardHeight +
                    widget.spacing *
                        (move.fromEndIndex - move.fromStartIndex)));

        int calculateToIndex(
            double cardInsertHeight, double spacing, int stackLength) {
          int index = ((cardInsertHeight + spacing) / spacing).floor();
          return index.clamp(0, stackLength);
        }

        move.toStartIndex = calculateToIndex(
            cardInsertHeight, widget.spacing, widget.digimonStack.length);

        gameState.moveCards(move, cards);
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double stackHeight = widget.cardHeight +
                (widget.spacing * (widget.digimonStack.length - 1));
            height = stackHeight.clamp(constraints.maxHeight, double.infinity);

            return SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                height: height,
                child: Opacity(
                  opacity: gameState.getDragStatus(widget.id) ? 0.5 : 1.0,
                  child:
                      Stack(clipBehavior: Clip.none, children: widget.children),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
