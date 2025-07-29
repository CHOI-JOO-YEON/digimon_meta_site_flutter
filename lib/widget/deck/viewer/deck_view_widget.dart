import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure to import the provider package

import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/widget/custom_slider_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/deck_scroll_gridview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_menu_bar.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_menu_buttons.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_description_view.dart';

import '../../../model/deck-build.dart';
import '../../../provider/deck_sort_provider.dart';

class DeckViewerView extends StatefulWidget {
  final DeckBuild deck;
  final Function(SearchParameter)? searchWithParameter;
  final int? fixedRowNumber; // 고정 행 수 (설정되면 슬라이더 숨김)
  final bool showMenuBar; // 메뉴바 표시 여부
  final bool showSlider; // 슬라이더 표시 여부
  final bool showButtons; // 버튼 표시 여부
  final bool showDeckInfo; // 덱 이름과 스탯 표시 여부

  const DeckViewerView({
    super.key,
    required this.deck,
    this.searchWithParameter,
    this.fixedRowNumber,
    this.showMenuBar = true,
    this.showSlider = true,
    this.showButtons = true,
    this.showDeckInfo = true,
  });

  @override
  State<DeckViewerView> createState() => _DeckViewerViewState();
}

class _DeckViewerViewState extends State<DeckViewerView> {
  int _rowNumber = 9;
  bool isInit = true;
  double _cardWidth = 100; // 기본값
  
  DeckSortProvider _deckSortProvider = DeckSortProvider();
  
  // 카드 크기 기준 컨테이너 radius 계산
  double get containerRadius => _cardWidth * 0.12;

  @override
  void initState() {
    super.initState();
    // fixedRowNumber가 설정되면 그 값을 사용
    if (widget.fixedRowNumber != null) {
      _rowNumber = widget.fixedRowNumber!;
    }
  }

  @override
  void didUpdateWidget(DeckViewerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // fixedRowNumber가 변경되면 _rowNumber 업데이트
    if (widget.fixedRowNumber != null && widget.fixedRowNumber != _rowNumber) {
      setState(() {
        _rowNumber = widget.fixedRowNumber!;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deckSortProvider.removeListener(_onDeckSortProviderChanged);
    _deckSortProvider = Provider.of<DeckSortProvider>(context);
    _deckSortProvider.addListener(_onDeckSortProviderChanged);
  }

  void _onDeckSortProviderChanged() {
    setState(() {
    });
  }

  @override
  void dispose() {
    _deckSortProvider.removeListener(_onDeckSortProviderChanged);
    super.dispose();
  }

  void updateRowNumber(int n) {
    _rowNumber = n;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    CardOverlayService cardOverlayService = CardOverlayService();
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    double height = MediaQuery.of(context).size.height * 0.88;
    if (isPortrait && isInit) {
      _rowNumber = 4;
    }
    isInit = false;
    
    return Column(
      children: [
        // 덱 정보 영역 - 세로모드에서 메뉴바와 스탯 표시
        if (isPortrait && widget.showDeckInfo) ...[
          Container(
            padding: EdgeInsets.all(SizeService.paddingSize(context) * 0.8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFFAFBFC),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 덱 메뉴바 (덱 이름, 작성자) - 안전하게 처리
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.deck.author ?? 'Unknown'}${widget.deck.authorId != null ? '#${(widget.deck.authorId! - 3).toString().padLeft(4, '0')}' : ''}',
                        style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.deck.deckName ?? 'Untitled Deck',
                        style: TextStyle(fontSize: SizeService.bodyFontSize(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: SizeService.paddingSize(context) * 0.5),
                // 덱 스탯 - 안전하게 처리
                Expanded(
                  flex: 3,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 60,
                      maxHeight: 100,
                    ),
                    child: DeckStat(deck: widget.deck),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeService.paddingSize(context) * 0.5),
        ],
        
        // 상단 메뉴 영역 - 가로모드에서만 표시
        if (!isPortrait && (widget.showMenuBar || widget.showSlider || widget.showButtons)) ...[
          SizedBox(
            height: height * 0.3,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 6.0 : 8.0),
              child: Column(
                children: [
                  if (widget.showMenuBar || widget.showSlider) ...[
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 메뉴바
                          if (widget.showMenuBar) ...[
                            Expanded(
                              flex: 2,
                              child: DeckViewerMenuBar(
                                deck: widget.deck,
                              ),
                            ),
                          ],
                          // 슬라이더 또는 고정 행 수 표시
                          if (widget.showSlider) ...[
                            Expanded(
                              flex: 2,
                              child: widget.fixedRowNumber == null
                                  ? CustomSlider(
                                      sliderValue: _rowNumber,
                                      sliderAction: updateRowNumber,
                                    )
                                  : Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          '${_rowNumber}열',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                          // 덱 통계
                          Expanded(
                            flex: 3,
                            child: DeckStat(deck: widget.deck),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (widget.showButtons) ...[
                    Expanded(
                      child: DeckMenuButtons(
                        deck: widget.deck,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        SizedBox(
          height: SizeService.bodyFontSize(context) * 1.5,
          child: Text(
            '메인',
            style: TextStyle(fontSize: SizeService.bodyFontSize(context)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(containerRadius),
          ),
          child: DeckScrollGridView(
            deckCount: widget.deck.deckMap,
            deck: widget.deck.deckCards,
            rowNumber: _rowNumber,
            isTama: false,
            cardOverlayService: cardOverlayService,
            searchWithParameter: widget.searchWithParameter,
            onCardSizeCalculated: (cardWidth) {
              if (_cardWidth != cardWidth) {
                setState(() {
                  _cardWidth = cardWidth;
                });
              }
            },
          ),
        ),
        SizedBox(
          height: SizeService.bodyFontSize(context) * 1.5,
          child: Text(
            '디지타마',
            style: TextStyle(fontSize: SizeService.bodyFontSize(context)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(containerRadius),
          ),
          child: DeckScrollGridView(
            deckCount: widget.deck.tamaMap,
            deck: widget.deck.tamaCards,
            rowNumber: _rowNumber,
            searchWithParameter: widget.searchWithParameter,
            isTama: true,
            cardOverlayService: cardOverlayService,
            onCardSizeCalculated: (cardWidth) {
              if (_cardWidth != cardWidth) {
                setState(() {
                  _cardWidth = cardWidth;
                });
              }
            },
          ),
        ),
        SizedBox(height: SizeService.paddingSize(context)),
        DeckDescriptionView(
          deck: widget.deck,
          searchWithParameter: widget.searchWithParameter,
        ),
      ],
    );
  }
}
