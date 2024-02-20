import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_count_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck_scroll_gridview_widget.dart';
import 'package:flutter/material.dart';

import '../model/card.dart';
import '../model/deck.dart';

class DeckView extends StatefulWidget {
  final Deck deck;
  // final Map<DigimonCard, int> deck;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(DigimonCard) cardPressEvent;

  const DeckView({super.key, required this.deck, this.mouseEnterEvent, required this.cardPressEvent});

  @override
  State<DeckView> createState() => _DeckViewState();
}

class _DeckViewState extends State<DeckView> {
  int _rowNumber = 8;

  void updateRowNumber(int n) {
    _rowNumber = n;
    setState(() {});
  }

  clearDeck(){
    print('c');
    widget.deck.clear();
    setState(() {

    });
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  //메뉴바
                  Expanded(flex: 3, child: DeckMenuBar(deck: widget.deck, clear: clearDeck)),

                  Expanded(flex: 1, child: DeckCount(deck: widget.deck,)),

                  //행에 한번에 표시되는 카드
                  Expanded(
                    flex:1,
                    child: CustomSlider(
                        sliderValue: _rowNumber, sliderAction: updateRowNumber),
                  ),
                  Expanded(flex:3, child: DeckStat(deck: widget.deck)),
                ],
              ),
            ),
          ),

          //덱그리드뷰
          Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: DeckScrollGridView(
                  deckCount: widget.deck.deckMap,
                  deck: widget.deck.deckCards,
                  rowNumber: _rowNumber,
                  mouseEnterEvent: widget.mouseEnterEvent,
                  cardPressEvent: widget.cardPressEvent,
                ),
              )),
          Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: DeckScrollGridView(
                  deckCount: widget.deck.tamaMap,
                  deck: widget.deck.tamaCards,
                  rowNumber: _rowNumber,
                  mouseEnterEvent: widget.mouseEnterEvent,
                  cardPressEvent: widget.cardPressEvent,
                ),
              ))
        ],
      );
    });
  }
}
