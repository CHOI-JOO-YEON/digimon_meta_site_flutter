import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/provider/deck_provider.dart';
import 'package:digimon_meta_site_flutter/provider/deck_sort_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/card/builder/card_scroll_grdiview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/builder/card_scroll_listview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:html' as html;
import 'package:digimon_meta_site_flutter/provider/note_provider.dart';
import 'package:provider/provider.dart';
import 'package:digimon_meta_site_flutter/widget/common/skeleton_loading.dart';
import '../widget/common/deck_menu_dialog.dart';
import '../widget/common/bottom_sheet_header.dart';

import '../model/card.dart';
import '../model/note.dart';
import '../widget/card/builder/card_search_bar.dart';

@RoutePage()
class DeckBuilderPage extends StatefulWidget {
  final String? searchParameterString;
  final DeckBuild? deck;
  final DeckView? deckView;

  const DeckBuilderPage({
    super.key,
    this.deck,
    @QueryParam('searchParameter') this.searchParameterString,
    this.deckView,
  });

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  final CardOverlayService _cardOverlayService = CardOverlayService();
  bool init = true;
  String viewMode = 'grid';
  final ScrollController _scrollController = ScrollController();
  final PanelController _panelController = PanelController();
  bool isSearchLoading = true;
  List<DigimonCard> cards = [];
  List<NoteDto> notes = [];
  int totalPages = 0;
  int currentPage = 0;
  int totalElements = 0;
  DeckBuild? deck;
  SearchParameter searchParameter = SearchParameter();
  DigimonCard? selectCard;
  Timer? _debounce;
  int _deckViewRowNumber = 4; // 세로 모드에서 덱 뷰의 행 수
  
  DeckSortProvider? _deckSortProvider;

  void updateSearchParameter() {
    context.navigateTo(DeckBuilderRoute(
        searchParameterString: json.encode(searchParameter.toJson()),
        deck: widget.deck));
  }

  void onViewModeChanged(String newMode) {
    viewMode = newMode;
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      _scrollController.dispose();
      _bottomSheetController.dispose();
      _debounce?.cancel();
      // DeckProvider 클리어
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      deckProvider.clearCurrentDeck();
      
      // DeckSortProvider 리스너 제거
      _deckSortProvider?.removeListener(_onDeckSortChanged);
    }

    super.dispose();
  }

  void _onDeckSortChanged() {
    // 덱 정렬이 변경되면 덱을 다시 정렬하고 화면을 업데이트
    try {
      if (mounted) {
        deck?.deckSort();
        setState(() {});
      }
    } catch (e) {
      // deck이 초기화되지 않았거나 다른 오류가 발생한 경우 무시
      print('Deck sort error: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () async {
      UserProvider().loginCheck();
      
      // DeckSortProvider 리스너 설정
      _deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
      _deckSortProvider?.addListener(_onDeckSortChanged);
      
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (!noteProvider.isInitialized) {
        await noteProvider.initialize();
      }
      notes = await noteProvider.getNotes();

      if (widget.searchParameterString != null) {
        searchParameter = SearchParameter.fromJson(
            json.decode(widget.searchParameterString!));
      }

      if (widget.deckView != null) {
        deck = DeckBuild.deckView(widget.deckView!, context);
        deck?.saveMapToLocalStorage();
        final deckProvider = Provider.of<DeckProvider>(context, listen: false);
        if (deck != null) deckProvider.setCurrentDeck(deck!);
      } else if (widget.deck != null) {
        deck = widget.deck!;
        deck?.saveMapToLocalStorage();
        final deckProvider = Provider.of<DeckProvider>(context, listen: false);
        if (deck != null) deckProvider.setCurrentDeck(deck!);
      } else {
        deck = DeckBuild(context);
        final deckProvider = Provider.of<DeckProvider>(context, listen: false);
        if (deck != null) deckProvider.setCurrentDeck(deck!);
        String? deckJsonString = html.window.localStorage['deck'];

        if (deckJsonString != null) {
          bool isLoading = false;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    title: const Text('저장된 덱 불러오기'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('이전에 작성 중이던 덱이 있습니다. 불러오시겠습니까?'),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    actions: [
                      if (!isLoading)
                        TextButton(
                          child: const Text('아니오'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            html.window.localStorage.remove('deck');
                          },
                        ),
                      if (!isLoading)
                        TextButton(
                          child: const Text('예'),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            DeckBuild? savedDeck = await DeckService()
                                .createDeckByLocalJsonString(
                                    deckJsonString, context);
                            if (savedDeck != null) {
                              deck = savedDeck;
                              final deckProvider = Provider.of<DeckProvider>(context, listen: false);
                              if (deck != null) deckProvider.setCurrentDeck(deck!);
                            }

                            setState(() {
                              isLoading = false;
                            });

                            Navigator.of(context).pop(true);
                            
                            // 덱 로드 후 상태 업데이트하여 에디터에 설명이 표시되도록 함
                            setState(() {});
                          },
                        ),
                    ],
                  );
                },
              );
            },
          );
        }
      }

      initSearch();
    });

    _scrollController.addListener(() {
      CardOverlayService().removeAllOverlays();
      _onScroll();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.orientationOf(context) == Orientation.portrait &&
          _panelController.isAttached) {
        _panelController.animatePanelToPosition(0.5);
      }
    });
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {});
  }

  @override
  void didUpdateWidget(covariant DeckBuilderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deck != oldWidget.deck) {
      setState(() {
        deck = widget.deck ?? DeckBuild(context);
        final deckProvider = Provider.of<DeckProvider>(context, listen: false);
        if (deck != null) deckProvider.setCurrentDeck(deck!);
      });
    }
    if (widget.searchParameterString != null &&
        widget.searchParameterString != oldWidget.searchParameterString) {
      searchParameter =
          SearchParameter.fromJson(json.decode(widget.searchParameterString!));
      initSearch();
    }
  }

  void searchWithParameter(SearchParameter parameter) {
    context.navigateTo(DeckBuilderRoute(
        searchParameterString: json.encode(parameter.toJson()),
        deck: widget.deck));
  }


  Future<void> initSearch() async {
    setState(() {
      isSearchLoading = true;
    });
    
    // 페이지 번호 초기화
    searchParameter.page = 1;
    
    CardResponseDto cardResponseDto =
        await CardDataService().searchCards(searchParameter);
    cards = cardResponseDto.cards!;
    totalPages = cardResponseDto.totalPages!;
    totalElements = cardResponseDto.totalElements!;
    currentPage = 1;
    searchParameter.page = 2;
    
    // 검색 결과에 따른 토스트 메시지 표시
    if (cards.isEmpty) {
      ToastOverlay.show(
        context, 
        '검색 결과가 없습니다. 다른 조건으로 검색해보세요.',
        type: ToastType.info,
      );
    } else if (searchParameter.searchString != null && searchParameter.searchString!.isNotEmpty) {
      ToastOverlay.show(
        context, 
        '${totalElements}개의 카드를 찾았습니다.',
        type: ToastType.success,
      );
    }
    
    setState(() {
      isSearchLoading = false;
    });
    
    // 검색 파라미터 URL 업데이트
    updateSearchParameter();
  }

  addCardByDeck(DigimonCard card) {
    String? result = deck?.addSingleCard(card);
    if (result != null) {
      if (result.contains("추가")) {
        ToastOverlay.show(context, result, type: ToastType.success);
      } else {
        ToastOverlay.show(context, result, type: ToastType.warning);
      }
    }
    setState(() {});
  }

  removeCardByDeck(DigimonCard card) {
    deck?.removeSingleCard(card);
    ToastOverlay.show(context, "카드가 제거되었습니다.", type: ToastType.info);
    setState(() {});
  }

  Future<void> loadMoreCard() async {
    CardResponseDto cardResponseDto =
        await CardDataService().searchCards(searchParameter);
    cards.addAll(cardResponseDto.cards!);
    currentPage = searchParameter.page++;
  }

  deckUpdate(DeckBuild deckBuild) {
    deck = deckBuild;
    setState(() {});
  }

  // 하단 시트 상태 관리
  final DraggableScrollableController _bottomSheetController = DraggableScrollableController();
  double _currentBottomSheetSize = 0.08;
  
  void _onBottomSheetChanged(double size) {
    setState(() {
      _currentBottomSheetSize = size;
    });
    
    // 오버레이 상태 업데이트 (동적 임계값 사용)
    final screenHeight = MediaQuery.sizeOf(context).height;
    final minSize = _calculateMinBottomSheetSize(screenHeight);
    final overlayThreshold = minSize * 1.5; // 최소 크기의 1.5배를 오버레이 임계값으로
    
    if (size > overlayThreshold) {
      _cardOverlayService.updatePanelStatus(true);
    } else {
      _cardOverlayService.updatePanelStatus(false);
    }
  }

  // 바텀시트 최소 크기 계산 (헤더가 완전히 보이도록)
  double _calculateMinBottomSheetSize(double screenHeight) {
    const double headerHeight = 80.0; // 헤더 고정 높이
    const double minRatio = 0.08; // 최소 8%
    const double maxRatio = 0.15; // 최대 15%
    
    double calculatedRatio = headerHeight / screenHeight;
    
    // 최소값과 최대값 사이로 제한
    return calculatedRatio.clamp(minRatio, maxRatio);
  }

  // 통합 덱 메뉴 다이얼로그
  void _showDeckMenu(BuildContext context) {
    if (deck != null) {
      DeckMenuDialog.show(
        context: context,
        deck: deck!,
        menuType: DeckMenuType.deckBuilder,
        deckViewRowNumber: _deckViewRowNumber,
        onRowNumberChanged: (value) {
          setState(() {
            _deckViewRowNumber = value;
          });
        },
        onDeckInit: () {
          if (deck != null) {
            deck!.init();
            setState(() {});
          }
        },
        onDeckClear: () {
          setState(() {});
        },
        onDeckImport: (deckBuild) {
          deckUpdate(deckBuild);
        },
        onDeckCopy: () {
          // DeckService.copyDeck()에서 이미 newCopy()를 호출하므로 여기서는 UI 업데이트만
          setState(() {});
        },
        onReload: () {
          setState(() {});
        },
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    
    if (isPortrait) {
      if (init) {
        viewMode = "list";
      }
    }
    init = false;

    if (isPortrait) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Scaffold(
          backgroundColor: Colors.grey[50],
          resizeToAvoidBottomInset: false, // 키보드가 올라와도 화면 크기 조정하지 않음
          body: Stack(
            children: [
              // 메인 컨텐츠 영역
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: constraints.maxHeight * _calculateMinBottomSheetSize(constraints.maxHeight), // 바텀시트 최소 크기만큼만 고정 공간 확보
                child: SafeArea(
                  child: Column(
                    children: [
                    // 검색바 영역
                    Container(
                      padding: EdgeInsets.all(SizeService.paddingSize(context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CardSearchBar(
                        notes: notes,
                        searchParameter: searchParameter,
                        onSearch: initSearch,
                        viewMode: viewMode,
                        onViewModeChanged: onViewModeChanged,
                        updateSearchParameter: updateSearchParameter,
                      ),
                    ),
                    
                    // 카드 목록 영역
                    Expanded(
                                              child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeService.paddingSize(context),
                          ),
                        child: !isSearchLoading
                            ? (viewMode == 'grid'
                                ? CardScrollGridView(
                                    cards: cards,
                                    rowNumber: _deckViewRowNumber,
                                    loadMoreCards: loadMoreCard,
                                    cardPressEvent: addCardByDeck,
                                    totalPages: totalPages,
                                    currentPage: currentPage,
                                    searchWithParameter: searchWithParameter,
                                  )
                                : CardScrollListView(
                                    cards: cards,
                                    loadMoreCards: loadMoreCard,
                                    cardPressEvent: addCardByDeck,
                                    totalPages: totalPages,
                                    currentPage: currentPage,
                                    searchWithParameter: searchWithParameter,
                                  ))
                            : viewMode == 'grid'
                                ? CardGridSkeletonLoading(
                                    crossAxisCount: _deckViewRowNumber,
                                    itemCount: 24,
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.7), // 스켈레톤 로딩에도 패딩 추가
                                    itemCount: 10,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                            CardSkeletonLoading(width: 80),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SkeletonLoading(
                                                    width: double.infinity,
                                                    height: 24,
                                                    borderRadius: 4,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  SkeletonLoading(
                                                    width: 200,
                                                    height: 16,
                                                    borderRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
                    // DraggableScrollableSheet으로 자연스러운 바텀시트 구현
      DraggableScrollableSheet(
        controller: _bottomSheetController,
        initialChildSize: _calculateMinBottomSheetSize(constraints.maxHeight),
        minChildSize: _calculateMinBottomSheetSize(constraints.maxHeight),
        maxChildSize: 1.0,
        snap: false,
                builder: (context, scrollController) {
                  return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      _onBottomSheetChanged(notification.extent);
                      return true;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: ClampingScrollPhysics(),
                        slivers: [
                          // 고정된 헤더 영역 (드래그 가능)
                          SliverToBoxAdapter(
                            child: Container(
                              height: 80,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    const Color(0xFFF8FAFC),
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: BottomSheetHeader(
                                deck: deck,
                                onMenuTap: () => _showDeckMenu(context),
                                showDragHandle: true,
                                enableMouseDrag: false, // 기본 드래그 동작 사용
                              ),
                            ),
                          ),
                          
                          // 구분선
                          if (_currentBottomSheetSize > _calculateMinBottomSheetSize(constraints.maxHeight) * 1.5)
                            SliverToBoxAdapter(
                              child: Divider(height: 1, color: Colors.grey[300]),
                            ),
                          
                          // 덱 상세 정보 영역 (독립적인 스크롤)
                          if (_currentBottomSheetSize > _calculateMinBottomSheetSize(constraints.maxHeight) * 1.5)
                            SliverToBoxAdapter(
                              child: Container(
                                height: constraints.maxHeight * _currentBottomSheetSize - 120, // 헤더 높이 제외
                                child: deck != null 
                                  ? SingleChildScrollView(
                                      physics: ClampingScrollPhysics(),
                                      padding: EdgeInsets.all(SizeService.paddingSize(context)),
                                      child: DeckBuilderView(
                                        deck: deck!,
                                        cardPressEvent: removeCardByDeck,
                                        import: deckUpdate,
                                        searchWithParameter: searchWithParameter,
                                        cardOverlayService: _cardOverlayService,
                                        showMenuBar: false, // 세로 모드에서는 메뉴바 숨김
                                        showSlider: false, // 세로 모드에서는 슬라이더 숨김
                                        showButtons: false, // 세로 모드에서는 버튼들 숨김
                                        showDeckNameOnly: true, // 세로 모드에서는 덱 이름만 표시
                                        fixedRowNumber: _deckViewRowNumber, // 조정 가능한 행 수 사용
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(50),
                                        child: Text(
                                          '덱이 비어있습니다',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      });
    } else {
      // 가로 모드 레이아웃 개선 - 모바일 반응형 추가
      final screenWidth = MediaQuery.sizeOf(context).width;
      final isTablet = screenWidth >= 768 && screenWidth < 1024;
      final isSmallLaptop = screenWidth >= 1024 && screenWidth < 1200;
      final isMobileDesktop = screenWidth < 768;
      
      // 동적 비율 계산
      int deckFlex, cardFlex;
      double spacing;
      
      if (isMobileDesktop) {
        // 모바일 데스크톱에서는 더 균형잡힌 비율
        deckFlex = 1;
        cardFlex = 1;
        spacing = MediaQuery.sizeOf(context).width * 0.005; // 더 작은 간격
      } else if (isTablet) {
        // 태블릿에서는 약간 조정된 비율
        deckFlex = 5;
        cardFlex = 3;
        spacing = MediaQuery.sizeOf(context).width * 0.008;
      } else if (isSmallLaptop) {
        // 작은 노트북에서는 기본 비율에 가깝게
        deckFlex = 3;
        cardFlex = 2;
        spacing = MediaQuery.sizeOf(context).width * 0.01;
      } else {
        // 큰 화면에서는 기존 비율 유지
        deckFlex = 3;
        cardFlex = 2;
        spacing = MediaQuery.sizeOf(context).width * 0.01;
      }
      
      return Padding(
        padding: EdgeInsets.all(
          isMobileDesktop 
            ? SizeService.paddingSize(context) * 0.5 // 모바일에서 패딩 줄임
            : SizeService.paddingSize(context)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: deckFlex,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isMobileDesktop ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: isMobileDesktop ? 12 : 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isMobileDesktop ? 16 : 20),
                  child: SingleChildScrollView(
                    child: deck != null ? DeckBuilderView(
                      deck: deck!,
                      cardPressEvent: removeCardByDeck,
                      import: deckUpdate,
                      searchWithParameter: searchWithParameter,
                      cardOverlayService: _cardOverlayService,
                    ) : Container(),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              flex: cardFlex,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isMobileDesktop ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: isMobileDesktop ? 12 : 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    isMobileDesktop 
                      ? SizeService.paddingSize(context) * 0.7 // 모바일에서 내부 패딩 줄임
                      : SizeService.paddingSize(context)
                  ),
                  child: Column(
                    children: [
                      // 검색바 높이를 화면 크기에 맞게 조정
                      SizedBox(
                        height: isMobileDesktop 
                          ? 60 // 모바일 가로모드에서도 충분한 높이
                          : (isSmallHeight ? 65 : 80), // 데스크톱에서 더 여유롭게
                        child: CardSearchBar(
                          notes: notes,
                          searchParameter: searchParameter,
                          onSearch: initSearch,
                          viewMode: viewMode,
                          onViewModeChanged: onViewModeChanged,
                          updateSearchParameter: updateSearchParameter,
                        ),
                      ),
                      SizedBox(
                        height: isMobileDesktop ? 3 : (isSmallHeight ? 4 : 8),
                      ), // 간격 조정
                      Expanded(
                          child: !isSearchLoading
                              ? (viewMode == 'grid'
                                  ? CardScrollGridView(
                                      cards: cards,
                                      rowNumber: 6, // 가로모드에서는 6개로 고정
                                      loadMoreCards: loadMoreCard,
                                      cardPressEvent: addCardByDeck,
                                      totalPages: totalPages,
                                      currentPage: currentPage,
                                      searchWithParameter: searchWithParameter,
                                    )
                                  : CardScrollListView(
                                      cards: cards,
                                      loadMoreCards: loadMoreCard,
                                      cardPressEvent: addCardByDeck,
                                      totalPages: totalPages,
                                      currentPage: currentPage,
                                      searchWithParameter: searchWithParameter,
                                    ))
                              : Padding(
                                  padding: EdgeInsets.all(isSmallHeight ? 8.0 : 16.0),
                                  child: viewMode == 'grid'
                                      ? CardGridSkeletonLoading(
                                          crossAxisCount: 6, // 가로모드에서는 6개로 고정
                                          itemCount: 24,
                                        )
                                      : ListView.builder(
                                          itemCount: 10,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                children: [
                                                  CardSkeletonLoading(
                                                    width: 80,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SkeletonLoading(
                                                          width: double.infinity,
                                                          height: 24,
                                                          borderRadius: 4,
                                                        ),
                                                        const SizedBox(height: 8),
                                                        SkeletonLoading(
                                                          width: 200,
                                                          height: 16,
                                                          borderRadius: 4,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

