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
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지

    if (isPortrait && isInit) {
      _rowNumber = 4;
    }
    isInit = false;
    
    return Column(
      children: [
        // 상단 메뉴 영역 - 충분한 공간 확보
        Padding(
          padding: EdgeInsets.all(SizeService.paddingSize(context)),
          child: Column(
            children: [
              // 메뉴바 영역 (고정 높이)
              Container(
                height: isSmallHeight ? 80 : 100,
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
              // 여백 추가
              SizedBox(height: SizeService.paddingSize(context)),
              // 버튼 영역 (고정 높이)
              Container(
                  height: SizeService.largeIconSize(context) + 16,
                  child: DeckMenuButtons(
                    deck: widget.deck,
                    init: initDeck,
                    import: widget.import,
                    newCopy: newCopy,
                    sortDeck: sortDeck,
                    reload: () {
                      setState(() {});
                    },
                  ),
                ),
            ],
          ),
        ),
        Container(
          height: SizeService.bodyFontSize(context) * 2.5,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.1),
                    const Color(0xFF1D4ED8).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    size: SizeService.bodyFontSize(context) * 1.2,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '메인',
                    style: TextStyle(
                      fontSize: SizeService.bodyFontSize(context) * 1.1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        NotificationListener<DeckDescriptionChangedNotification>(
          onNotification: (notification) {
            // 알림을 처리하고 상위 위젯으로 전파하지 않음
            return true; 
          },
          child: Expanded(
            flex: _isEditorExpanded 
              ? (isSmallHeight ? 3 : 4)  // 확장 시: 작은 화면에서는 3, 일반 화면에서는 4
              : 1,                       // 축소 시: 모든 화면에서 1
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color(0xFFFAFBFC),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
        ),
        Container(
          height: SizeService.bodyFontSize(context) * 2.5,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.1),
                    const Color(0xFF6D28D9).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: SizeService.bodyFontSize(context) * 1.2,
                    color: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '디지타마',
                    style: TextStyle(
                      fontSize: SizeService.bodyFontSize(context) * 1.1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
