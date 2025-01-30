import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class DraggableDigimonListWidget extends StatefulWidget {
  final String id;
  final double cardWidth;
  final List<Widget> children;

  const DraggableDigimonListWidget({
    super.key,
    required this.id,
    required this.children,
    required this.cardWidth,
  });

  @override
  State<DraggableDigimonListWidget> createState() =>
      _DraggableDigimonListWidgetState();
}

class _DraggableDigimonListWidgetState
    extends State<DraggableDigimonListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    double cardHeight = widget.cardWidth * 1.404;

    final ScrollController scrollController = ScrollController();
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
        final double scrollOffset = scrollController.offset;
        final double localX = box.globalToLocal(details.offset).dx;
        final double effectiveX = localX + scrollOffset;

        int calculateToIndex(double effectiveX, double cardWidth) {
          int index = ((effectiveX + cardWidth) / cardWidth).floor();
          return index.clamp(0, widget.children.length);
        }

        move.toStartIndex = calculateToIndex(effectiveX, widget.cardWidth);

        gameState.moveCards(move, cards);
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
            height: cardHeight,
            child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: RawScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    thickness: 8.0,
                    radius: const Radius.circular(4.0),
                    thumbColor: Colors.blueAccent,
                    trackColor: Colors.blue.shade100,
                    trackBorderColor: Colors.blue.shade300,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      children: widget.children,
                    ))));
      },
    );
  }
}
