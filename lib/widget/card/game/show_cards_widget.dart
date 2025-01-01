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

class ShowCards extends StatelessWidget {
  final double cardWidth;

  final String id = 'shows';

  const ShowCards({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    final ScrollController scrollController = ScrollController();

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
        final data = details.data;
        final sourceId = data['sourceId'] as String? ?? '';
        final fromIndex = data['fromIndex'] as int? ?? -1;
        final card = data['card'] as DigimonCard?;
        final draggedCards = data['cards'] as List<DigimonCard>?;

        final renderBox = context.findRenderObject() as RenderBox;
        final localOffset = renderBox.globalToLocal(details.offset);

        final scrollOffset =
            scrollController.hasClients ? scrollController.offset : 0.0;
        final adjustedX = localOffset.dx + scrollOffset;

        int toIndex = (adjustedX / cardWidth).floor();

        if (toIndex < fromIndex) {
          toIndex = ((adjustedX + cardWidth) / cardWidth).floor();
        }

        if (sourceId == id) {
          toIndex = toIndex.clamp(0, gameState.hand.length - 1);
          gameState.reorderShow(fromIndex, toIndex);
          return;
        }

        toIndex = toIndex.clamp(0, gameState.hand.length);
        if (draggedCards?.isNotEmpty == true) {
          for (var i = draggedCards!.length - 1; i >= 0; i--) {
            gameState.addCardToShowsAt(draggedCards[i], toIndex++);
          }
          if (data['removeCards'] != null) {
            data['removeCards']();
          }
        } else if (card != null) {
          gameState.addCardToShowsAt(card, toIndex);
          if (data['removeCard'] != null) {
            data['removeCard']();
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: RawScrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 8.0,
            radius: const Radius.circular(4.0),
            thumbColor: Colors.blueAccent,
            trackColor: Colors.blue.shade100,
            trackBorderColor: Colors.blue.shade300,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: gameState.shows.length,
              itemBuilder: (context, index) {
                final card = gameState.shows[index];
                return Draggable<Map<String, dynamic>>(
                  data: {
                    'card': card,
                    'fromIndex': index,
                    'sourceId': id,
                    'removeCard': () {
                      gameState.removeCardFromShowsAt(index);
                    },
                  },
                  feedback: ChangeNotifierProvider.value(
                    value: gameState,
                    child: Material(
                      color: Colors.transparent,
                      child: CardWidget(
                        card: card,
                        cardWidth: cardWidth,
                        rest: () {},
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: CardWidget(
                      card: card,
                      cardWidth: cardWidth,
                      rest: () {},
                    ),
                  ),
                  child: CardWidget(
                    card: card,
                    cardWidth: cardWidth,
                    rest: () {},
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
