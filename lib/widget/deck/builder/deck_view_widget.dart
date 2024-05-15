import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_buttons.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_scroll_gridview_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../model/card.dart';
import '../../../model/deck.dart';
import '../../../model/deck_response_dto.dart';

class DeckBuilderView extends StatefulWidget {
  final Deck deck;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(DigimonCard) cardPressEvent;
  final Function(DeckResponseDto) import;
  final Function(int)? searchNote;

  const DeckBuilderView(
      {super.key,
      required this.deck,
      this.mouseEnterEvent,
      required this.cardPressEvent,
      required this.import, this.searchNote});

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
    textEditingController.text='My Deck';
    setState(() {});
  }

  newCopy(){
    widget.deck.newCopy();

    textEditingController.text=widget.deck.deckName;
    setState(() {

    });
  }

  addCard(DigimonCard digimonCard) {
    widget.deck.addCard(digimonCard,context);
    setState(() {

    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(mounted) {
      textEditingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if(isPortrait&&isInit){
      _rowNumber=6;
    }
    isInit= false;
    return Column(
        children: [
          Expanded(
            flex: 6,
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
                          flex: 2,
                          child: CustomSlider(
                              sliderValue: _rowNumber, sliderAction: updateRowNumber),
                        ),
                        Expanded(flex: 3, child: DeckStat(deck: widget.deck)),
                      ],
                    ),
                  ),
                  Expanded(flex: 2, child: DeckMenuButtons(
                    deck: widget.deck,
                    clear: clearDeck,
                    init: initDeck,
                    import: widget.import,
                    newCopy: newCopy, reload: () {setState(() {

                    });  },
                  )),

                ],
              ),
            ),
          ),

          //덱그리드뷰
          Expanded(
              flex: 14,
              child: Container(
                decoration: BoxDecoration(
                color:  Theme.of(context).cardColor,
                    // color: Color.fromRGBO(255, 255, 240, 1),
                    //   color: Color(0xFFFFF9E3),
                    borderRadius: BorderRadius.circular(5)),
                child: DeckScrollGridView(
                  deckCount: widget.deck.deckMap,
                  deck: widget.deck.deckCards,
                  rowNumber: _rowNumber,
                  mouseEnterEvent: widget.mouseEnterEvent,
                  cardPressEvent: widget.cardPressEvent,
                  onLongPress: addCard,
                  searchNote: widget.searchNote,
                ),
              )),
          Expanded(flex: 1, child: Container()),
          Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                    color:  Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(5)),
                child: DeckScrollGridView(
                  deckCount: widget.deck.tamaMap,
                  deck: widget.deck.tamaCards,
                  rowNumber: _rowNumber,
                  mouseEnterEvent: widget.mouseEnterEvent,
                  cardPressEvent: widget.cardPressEvent,
                  onLongPress: addCard,
                  searchNote: widget.searchNote,
                ),
              ))
        ],

    );
  }
}
