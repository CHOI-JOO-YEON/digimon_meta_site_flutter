
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_count_widget.dart';
import 'package:flutter/material.dart';

import '../../../model/deck.dart';
class DeckBuilderMenuBar extends StatefulWidget {
  final Deck deck;
  final TextEditingController textEditingController;

  const DeckBuilderMenuBar(
      {super.key,
      required this.deck, required this.textEditingController,
      });

  @override
  State<DeckBuilderMenuBar> createState() => _DeckBuilderMenuBarState();
}

class _DeckBuilderMenuBarState extends State<DeckBuilderMenuBar> {

  @override
  void didUpdateWidget(covariant DeckBuilderMenuBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deck != oldWidget.deck) {
      setState(() {
        widget.textEditingController.text = widget.deck.deckName ?? 'My Deck';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.textEditingController.text = widget.deck.deckName;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextField(
                        controller: widget.textEditingController,
                        onChanged: (v) {
                          widget.deck.deckName = v;
                        },
                      ))
                    ],
                  ),
                ),
              )),
          Expanded(child: SizedBox(
              width: constraints.maxWidth,
              child: DeckCount(deck: widget.deck,)))
        ],
      );
    });
  }
}
