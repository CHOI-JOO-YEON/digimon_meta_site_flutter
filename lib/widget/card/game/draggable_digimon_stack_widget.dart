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

  void _scrollUp() {
    if (_scrollController.hasClients) {
      final double scrollAmount = widget.spacing * 2; // 2카드 간격만큼 스크롤
      _scrollController.animateTo(
        (_scrollController.offset - scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      final double scrollAmount = widget.spacing * 2; // 2카드 간격만큼 스크롤
      _scrollController.animateTo(
        (_scrollController.offset + scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
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

        gameState.moveCards(move, cards, true);
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
                        double stackHeight = widget.cardHeight +
                (widget.spacing * (widget.digimonStack.length - 1));
            height = stackHeight.clamp(constraints.maxHeight, double.infinity);
            
            // 스크롤이 필요한지 확인
            bool needsScroll = stackHeight > constraints.maxHeight;

            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: height,
                    child: Opacity(
                      opacity: gameState.getDragStatus(widget.id) ? 0.5 : 1.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: widget.children,
                      ),
                    ),
                  ),
                ),
                // 스크롤 버튼들 (스크롤이 필요할 때만 표시)
                if (needsScroll)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildScrollButton(
                              icon: Icons.keyboard_arrow_up,
                              onPressed: _scrollUp,
                            ),
                            Container(
                              width: 1,
                              height: 4,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            _buildScrollButton(
                              icon: Icons.keyboard_arrow_down,
                              onPressed: _scrollDown,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
