import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_scroll_gridview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_menu_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../model/deck.dart';

class DeckViewerView extends StatefulWidget {
  final Deck deck;
  final Function(int)? searchNote;

  const DeckViewerView({
    super.key,
    required this.deck, this.searchNote,
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
    CardOverlayService _cardOverlayService = CardOverlayService();
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    double height = MediaQuery.of(context).size.height * 0.88;
    if(isPortrait&&isInit){
      _rowNumber=4;
    }
    isInit=false;
    return Column(
      children: [
        SizedBox(
          height: height*0.3,
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


                      //행에 한번에 표시되는 카드
                      Expanded(
                        flex: isPortrait?1:2,
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
        SizedBox(
          height: height*0.03,
          child: Container(child: Text('메인', style: TextStyle(fontSize: height*0.02))),
        ),
        //덱그리드뷰
        Container(
          decoration: BoxDecoration(
              // color: Color.fromRGBO(255, 255, 240, 1),
            color:  Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5)),
          child: DeckScrollGridView(
            deckCount: widget.deck.deckMap,
            deck: widget.deck.deckCards,
            rowNumber: _rowNumber,
            searchNote: widget.searchNote,
            isTama: false,
            cardOverlayService: _cardOverlayService,
            // mouseEnterEvent: widget.mouseEnterEvent,
          ),
        ),
        SizedBox(
          height: height*0.03,
          child: Container(child: Text('디지타마', style: TextStyle(fontSize: height*0.02))),
        ),
        Container(
          decoration: BoxDecoration(
              color:  Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5)),
          child: DeckScrollGridView(
            deckCount: widget.deck.tamaMap,
            deck: widget.deck.tamaCards,
            rowNumber: _rowNumber,
            searchNote: widget.searchNote,
            isTama: true,
            cardOverlayService: _cardOverlayService,
            // mouseEnterEvent: widget.mouseEnterEvent,
          ),
        ),

      ],
    );
  }
}
