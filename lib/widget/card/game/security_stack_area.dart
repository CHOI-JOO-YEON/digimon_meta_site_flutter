import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';
import 'card_back_widget.dart';
import 'draggable_card_widget.dart';
import 'draggable_digimon_stack_widget.dart';

class SecurityStackArea extends StatelessWidget {
  final double cardWidth;

  const SecurityStackArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    double cardHeight = cardWidth * 1.404;
    double cardSpacing = cardHeight * 0.16;
    List<DigimonCard> cards = gameState.securityStack;
    String id = 'security';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '시큐리티 (${gameState.securityStack.length})',
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => gameState.shuffleSecurity(),
              icon: Icon(Icons.shuffle),
              tooltip: '셔플',
            ),
            IconButton(
              onPressed: () => gameState.flipAllSecurity(true),
              icon: Icon(Icons.tag_faces),
              tooltip: '전체 앞면',
            ),
            IconButton(
              onPressed: () => gameState.flipAllSecurity(false),
              icon: Icon(Icons.flip),
              tooltip: '전체 뒷면',
            ),
            IconButton(
              onPressed: () => gameState.recoveryFromDeck(),
              icon: Icon(Icons.health_and_safety_outlined),
              tooltip: '리커버리(덱)',
            )
          ],
        ),
        Expanded(
          child: DraggableDigimonStackWidget(
            digimonStack: cards,
            id: id,
            cardHeight: cardWidth,
            spacing: cardSpacing,
            children: [
              ...cards.asMap().entries.map((entry) {
                return SecurityCardWidget(
                  card: entry.value,
                  cardWidth: cardWidth,
                  index: entry.key,
                  spacing: cardSpacing,
                  id: id,
                  gameState: gameState,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class SecurityCardWidget extends StatefulWidget {
  final DigimonCard card;
  final double cardWidth;
  final int index;
  final double spacing;
  final String id;
  final GameState gameState;

  const SecurityCardWidget(
      {super.key,
      required this.card,
      required this.cardWidth,
      required this.index,
      required this.spacing,
      required this.id,
      required this.gameState});

  @override
  _SecurityCardWidgetState createState() => _SecurityCardWidgetState();
}

class _SecurityCardWidgetState extends State<SecurityCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.index * widget.spacing,
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            widget.gameState.securityFlipStatus[widget.index]
                ? Draggable<MoveCard>(
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedbackOffset: const Offset(10, 0),
                    data: MoveCard(
                        fromId: widget.id,
                        fromStartIndex: widget.index,
                        fromEndIndex: widget.index),
                    feedback: ChangeNotifierProvider.value(
                      value: widget.gameState,
                      child: Material(
                        color: Colors.transparent,
                        child: CardWidget(
                          card: widget.card,
                          cardWidth: widget.cardWidth * 0.85,
                          rest: () {},
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: CardWidget(
                            card: widget.card,
                            cardWidth: widget.cardWidth,
                            rest: () {},
                          ),
                        )),
                    child: SizedBox(
                        width: widget.cardWidth * 1.404,
                        height: widget.cardWidth,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: CardWidget(
                            card: widget.card,
                            cardWidth: widget.cardWidth,
                            rest: () {},
                          ),
                        )))
                : RotatedBox(
                    quarterTurns: 3,
                    child: CardBackWidget(width: widget.cardWidth)),
            IconButton(
                onPressed: () => widget.gameState.flipSecurity(widget.index),
                icon: Icon(Icons.flip))
          ],
        ),
      ),
    );
  }
}
