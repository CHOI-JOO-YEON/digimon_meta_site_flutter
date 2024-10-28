import 'package:digimon_meta_site_flutter/widget/deck/deck_count_widget.dart';
import 'package:digimon_meta_site_flutter/widget/tab_tooltip.dart';
import 'package:flutter/material.dart';

import '../../../model/deck-build.dart';

class DeckBuilderMenuBar extends StatefulWidget {
  final DeckBuild deck;
  final TextEditingController textEditingController;

  const DeckBuilderMenuBar({
    super.key,
    required this.deck,
    required this.textEditingController,
  });

  @override
  State<DeckBuilderMenuBar> createState() => _DeckBuilderMenuBarState();
}

class _DeckBuilderMenuBarState extends State<DeckBuilderMenuBar> {
  final GlobalKey<State<Tooltip>> tooltipKey = GlobalKey<State<Tooltip>>();

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
      final isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;
      double fontSize =
          isPortrait ? constraints.maxWidth * 0.1 : constraints.maxWidth * 0.05;
      return Column(
        children: [
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Expanded(flex: 1, child: Container(),),
                      Expanded(
                          flex: 12,
                          child: TextField(
                            style: TextStyle(fontSize: fontSize),
                            controller: widget.textEditingController,
                            onChanged: (v) {
                              widget.deck.deckName = v;
                            },
                          )),
                      Expanded(
                          flex: 2,
                          child: widget.deck.isSave
                              ? Container()
                              : const TabTooltip(
                                  message: '변경 사항이 저장되지 않았습니다.',
                                  child:
                                      Icon(Icons.warning, color: Colors.amber),
                                )),
                    ],
                  ),
                ),
              )),
          Expanded(
              flex: 2,
              child: SizedBox(
                  width: constraints.maxWidth,
                  child: DeckCount(
                    deck: widget.deck,
                  )))
        ],
      );
    });
  }
}
