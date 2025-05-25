import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_buttons.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_editor_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_scroll_gridview_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../model/card.dart';
import '../../../model/deck-build.dart';

// 덱 설명 변경 알림용 클래스
class DeckDescriptionChangedNotification extends Notification {
  final DeckBuild deck;
  
  DeckDescriptionChangedNotification(this.deck);
}

class DeckBuilderView extends StatefulWidget {
  final DeckBuild deck;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(DigimonCard) cardPressEvent;
  final Function(DeckBuild) import;
  final Function(SearchParameter)? searchWithParameter;
  final CardOverlayService cardOverlayService;

  const DeckBuilderView(
      {super.key,
      required this.deck,
      this.mouseEnterEvent,
      required this.cardPressEvent,
      required this.import,
      this.searchWithParameter,
      required this.cardOverlayService});

  @override
  State<DeckBuilderView> createState() => _DeckBuilderViewState();
}

class _DeckBuilderViewState extends State<DeckBuilderView> {
  TextEditingController textEditingController = TextEditingController();
  bool isInit = true;
  int _rowNumber = 9;
  bool _isEditorExpanded = false;

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
    // 덱 설명이 초기화되었음을 알림
    DeckDescriptionChangedNotification(widget.deck).dispatch(context);
    setState(() {});
  }

  newCopy() {
    widget.deck.newCopy();
    textEditingController.text = widget.deck.deckName;
    // 덱 설명이 초기화되었음을 알림
    DeckDescriptionChangedNotification(widget.deck).dispatch(context);
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

  sortDeck(List<String> sortPriority) {
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      textEditingController.dispose();
    }
    super.dispose();
  }

  void toggleEditorExpanded(bool expanded) {
    setState(() {
      _isEditorExpanded = expanded;
    });
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
          height: height * 0.3,
          child: Padding(
            padding: EdgeInsets.all(SizeService.paddingSize(context)),
            child: Column(
              children: [
                Expanded(
                  // flex: 4,
                  child: Row(
                    children: [
                      //메뉴바
                      Expanded(
                          flex: 2,
                          child: DeckBuilderMenuBar(
                            deck: widget.deck,
                            textEditingController: textEditingController,
                          )),
                      Expanded(
                        flex: 2,
                        child: CustomSlider(
                            sliderValue: _rowNumber,
                            sliderAction: updateRowNumber),
                      ),
                      Expanded(flex: 3, child: DeckStat(deck: widget.deck)),
                    ],
                  ),
                ),
                Expanded(
                    child: DeckMenuButtons(
                  deck: widget.deck,
                  init: initDeck,
                  import: widget.import,
                  newCopy: newCopy,
                  sortDeck: sortDeck,
                  reload: () {
                    setState(() {});
                  },
                )),
              ],
            ),
          ),
        ),
        SizedBox(
          height: SizeService.bodyFontSize(context) * 1.5,
          child: Center(child: Text('메인', style: TextStyle(fontSize: SizeService.bodyFontSize(context)))),
        ),
        NotificationListener<DeckDescriptionChangedNotification>(
          onNotification: (notification) {
            // 알림을 처리하고 상위 위젯으로 전파하지 않음
            return true; 
          },
          child: Expanded(
            flex: _isEditorExpanded ? 4 : 1,
            child: DeckEditorWidget(
              deck: widget.deck,
              onEditorChanged: () {
                setState(() {});
                widget.deck.saveMapToLocalStorage();
              },
              searchWithParameter: widget.searchWithParameter,
              isExpanded: _isEditorExpanded,
              toggleExpanded: toggleEditorExpanded,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(SizeService.roundRadius(context))),
          child: DeckScrollGridView(
            deckCount: widget.deck.deckMap,
            deck: widget.deck.deckCards,
            rowNumber: _rowNumber,
            searchWithParameter: widget.searchWithParameter,
            addCard: addCard,
            removeCard: removeCard,
            isTama: false,
            cardOverlayService: widget.cardOverlayService,
          ),
        ),
        SizedBox(
          height: SizeService.bodyFontSize(context) * 1.5,
          child: Center(
              child: Text('디지타마', style: TextStyle(fontSize: SizeService.bodyFontSize(context)))),
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(SizeService.roundRadius(context))),
          child: DeckScrollGridView(
            deckCount: widget.deck.tamaMap,
            deck: widget.deck.tamaCards,
            rowNumber: _rowNumber,
            searchWithParameter: widget.searchWithParameter,
            addCard: addCard,
            removeCard: removeCard,
            isTama: true,
            cardOverlayService: widget.cardOverlayService,
          ),
        ),
      ],
    );
  }
}
