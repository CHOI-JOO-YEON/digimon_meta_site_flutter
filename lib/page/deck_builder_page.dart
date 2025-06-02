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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:html' as html;
import 'package:digimon_meta_site_flutter/provider/note_provider.dart';
import 'package:provider/provider.dart';
import 'package:digimon_meta_site_flutter/widget/common/skeleton_loading.dart';

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

  DeckBuild? deck;
  SearchParameter searchParameter = SearchParameter();
  DigimonCard? selectCard;
  Timer? _debounce;
  
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
      if (MediaQuery.of(context).orientation == Orientation.portrait &&
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
        '${cards.length}개의 카드를 찾았습니다.',
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

  bool _overlayRemoved = false;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      if (init) {
        viewMode = "list";
      }
    }
    init = false;

    if (isPortrait) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SlidingUpPanel(
          onPanelSlide: (v) {
            if (v > 0.1) {
              _cardOverlayService.updatePanelStatus(true);
            } else {
              _cardOverlayService.updatePanelStatus(false);
            }
            _overlayRemoved = false;
          },
          controller: _panelController,
          renderPanelSheet: false,
          minHeight: 50,
          snapPoint: 0.5,
          maxHeight: constraints.maxHeight,
          isDraggable: false,
          panelBuilder: (ScrollController sc) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      BorderRadius.circular(SizeService.roundRadius(context))),
              child: Padding(
                padding: EdgeInsets.only(
                    left: SizeService.paddingSize(context),
                    right: SizeService.paddingSize(context),
                    bottom: SizeService.paddingSize(context)),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextButton(
                                onPressed: () {
                                  _scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Text(
                                  '메인',
                                  style: TextStyle(
                                      fontSize:
                                          SizeService.bodyFontSize(context)),
                                )),
                          ),
                          Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _panelController.panelPosition >
                                            0.3
                                        ? () {
                                            if (_panelController.panelPosition >
                                                0.7) {
                                              _panelController
                                                  .animatePanelToSnapPoint()
                                                  .then((_) {
                                                setState(() {});
                                              });
                                            } else {
                                              _panelController
                                                  .close()
                                                  .then((_) {
                                                setState(() {});
                                              });
                                            }
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color:
                                          _panelController.panelPosition > 0.3
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '카드 검색 패널',
                                    style: TextStyle(
                                        fontSize:
                                            SizeService.bodyFontSize(context),
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  IconButton(
                                    onPressed: _panelController.panelPosition <
                                            0.7
                                        ? () {
                                            if (_panelController.panelPosition <
                                                0.3) {
                                              _panelController
                                                  .animatePanelToSnapPoint()
                                                  .then((_) {
                                                setState(() {});
                                              });
                                            } else {
                                              _panelController.open().then((_) {
                                                setState(() {});
                                              });
                                            }
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.arrow_drop_up,
                                      color:
                                          _panelController.panelPosition < 0.7
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 1,
                            child: TextButton(
                                onPressed: () {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Text(
                                  '타마',
                                  style: TextStyle(
                                      fontSize:
                                          SizeService.bodyFontSize(context)),
                                )),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            SizedBox(
                                height: 50,
                                child: CardSearchBar(
                                  notes: notes,
                                  searchParameter: searchParameter,
                                  onSearch: initSearch,
                                  viewMode: viewMode,
                                  onViewModeChanged: onViewModeChanged,
                                  updateSearchParameter: updateSearchParameter,
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Expanded(
                                flex: 9,
                                child: !isSearchLoading
                                    ? (viewMode == 'grid'
                                        ? CardScrollGridView(
                                            cards: cards,
                                            rowNumber: 6,
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
                                        padding: const EdgeInsets.all(16.0),
                                        child: viewMode == 'grid'
                                            ? CardGridSkeletonLoading(
                                                crossAxisCount: 6,
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
                            Expanded(
                                flex: _panelController.panelPosition < 0.7
                                    ? 11
                                    : 0,
                                child: Container())
                          ],
                        )),
                  ],
                ),
              ),
            );
          },
          body: Container(
            color: Theme.of(context).highlightColor,
            padding: EdgeInsets.all(SizeService.paddingSize(context)),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  if (deck != null) DeckBuilderView(
                    deck: deck!,
                    cardPressEvent: removeCardByDeck,
                    import: deckUpdate,
                    searchWithParameter: searchWithParameter,
                    cardOverlayService: _cardOverlayService,
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                  )
                ],
              ),
            ),
          ),
        );
      });
    } else {
      return Padding(
        padding: EdgeInsets.all(SizeService.paddingSize(context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeService.roundRadius(context)),
                    color: Theme.of(context).highlightColor),
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
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.01,
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius:
                      BorderRadius.circular(SizeService.roundRadius(context)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(SizeService.paddingSize(context)),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child: CardSearchBar(
                            notes: notes,
                            searchParameter: searchParameter,
                            onSearch: initSearch,
                            viewMode: viewMode,
                            onViewModeChanged: onViewModeChanged,
                            updateSearchParameter: updateSearchParameter,
                          )),
                      Expanded(
                          flex: 9,
                          child: !isSearchLoading
                              ? (viewMode == 'grid'
                                  ? CardScrollGridView(
                                      cards: cards,
                                      rowNumber: 6,
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
                                  padding: const EdgeInsets.all(16.0),
                                  child: viewMode == 'grid'
                                      ? CardGridSkeletonLoading(
                                          crossAxisCount: 6,
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
