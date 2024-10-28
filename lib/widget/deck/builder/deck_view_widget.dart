import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_buttons.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_scroll_gridview_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../model/card.dart';
import '../../../model/deck-build.dart';
import '../../../model/deck-view.dart';

class DeckBuilderView extends StatefulWidget {
  final DeckBuild deck;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(DigimonCard) cardPressEvent;
  final Function(DeckView) import;
  final Function(int)? searchNote;
  final CardOverlayService cardOverlayService;

  const DeckBuilderView(
      {super.key,
      required this.deck,
      this.mouseEnterEvent,
      required this.cardPressEvent,
      required this.import,
      this.searchNote,
      required this.cardOverlayService});

  @override
  State<DeckBuilderView> createState() => _DeckBuilderViewState();
}

class _DeckBuilderViewState extends State<DeckBuilderView> {
  TextEditingController textEditingController = TextEditingController();
  bool isInit = true;
  int _rowNumber = 9;

  void updateRowNumber(int n) {
    _rowNumber = n;
    setState(() {});
  }

  clearDeck() {
    widget.deck.clear();

    setState(() {});
  }

  initDeck() {
    widget.deck.init();
    textEditingController.text = 'My Deck';
    setState(() {});
  }

  newCopy() {
    widget.deck.newCopy();

    textEditingController.text = widget.deck.deckName;
    setState(() {});
  }

  addCard(DigimonCard card) {
    widget.deck.addSingleCard(card);
    setState(() {});
  }

  removeCard(DigimonCard card) {
    widget.deck.removeSingleCard(card);
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      textEditingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    double height = MediaQuery.of(context).size.height * 0.88;
    if (isPortrait && isInit) {
      _rowNumber = 4;
    }
    isInit = false;
    return Column(
      children: [
        SizedBox(
          height: height*0.3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      //메뉴바
                      Expanded(
                          flex: 2,
                          child: DeckBuilderMenuBar(
                            deck: widget.deck,
                            textEditingController: textEditingController,
                          )),

                      //행에 한번에 표시되는 카드
                      Expanded(
                        flex: isPortrait ? 1 : 2,
                        child: CustomSlider(
                            sliderValue: _rowNumber,
                            sliderAction: updateRowNumber),
                      ),
                      Expanded(flex: 3, child: DeckStat(deck: widget.deck)),
                    ],
                  ),
                ),
                Expanded(
                    // flex: 2,
                    child: DeckMenuButtons(
                      deck: widget.deck,
                      clear: clearDeck,
                      init: initDeck,
                      import: widget.import,
                      newCopy: newCopy,
                      reload: () {
                        setState(() {});
                      },
                    )),
              ],
            ),
          ),
        ),
        SizedBox(
          height: height*0.03,
          child: Text('메인', style: TextStyle(fontSize: height*0.02)),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5)),
          child: DeckScrollGridView(
            deckCount: widget.deck.deckMap,
            deck: widget.deck.deckCards,
            rowNumber: _rowNumber,
            searchNote: widget.searchNote,
            addCard: addCard,
            removeCard: removeCard,
            isTama: false,
            cardOverlayService: widget.cardOverlayService,
          ),
        ),
        SizedBox(
          height: height*0.03,
          child: Container(child: Text('디지타마', style: TextStyle(fontSize: height*0.02))),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5)),
          child: DeckScrollGridView(
            deckCount: widget.deck.tamaMap,
            deck: widget.deck.tamaCards,
            rowNumber: _rowNumber,
            searchNote: widget.searchNote,
            addCard: addCard,
            removeCard: removeCard,
            isTama: true,
            cardOverlayService: widget.cardOverlayService,
          ),
        ),

        //덱그리드뷰
      ],
    );
  }
}
