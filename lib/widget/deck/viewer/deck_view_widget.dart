import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_count_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_scroll_gridview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_menu_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/card.dart';
import '../../../model/deck.dart';
import '../../../model/deck_response_dto.dart';

class DeckViewerView extends StatefulWidget {
  final Deck deck;

  // final Function(DigimonCard)? mouseEnterEvent;

  const DeckViewerView({
    super.key,
    required this.deck,
    // this.mouseEnterEvent,
  });

  @override
  State<DeckViewerView> createState() => _DeckViewerViewState();
}

class _DeckViewerViewState extends State<DeckViewerView> {
  int _rowNumber = 9;
  bool isInit = true;
  void updateRowNumber(int n) {
    _rowNumber = n;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if(isPortrait&&isInit){
      _rowNumber=6;
    }
    isInit=false;
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex:  4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //메뉴바
                      Expanded(
                          flex: 2,
                          child: DeckViewerMenuBar(
                            deck: widget.deck,
                          )),

                      // Expanded(
                      //     flex: 1,
                      //     child: Container(),
                      // ),

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
                ))
              ],
            ),
          ),
        ),

        //덱그리드뷰
        Expanded(
            flex: 14,
            child: Container(
              decoration: BoxDecoration(
                  // color: Color.fromRGBO(255, 255, 240, 1),
                color:  Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5)),
              child: DeckScrollGridView(
                deckCount: widget.deck.deckMap,
                deck: widget.deck.deckCards,
                rowNumber: _rowNumber,
                // mouseEnterEvent: widget.mouseEnterEvent,
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
                // mouseEnterEvent: widget.mouseEnterEvent,
              ),
            ))
      ],
    );
  }
}
