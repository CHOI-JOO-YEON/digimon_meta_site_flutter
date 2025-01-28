import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/service/type_service.dart';
import 'package:digimon_meta_site_flutter/widget/card/builder/card_scroll_grdiview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/builder/card_scroll_listview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_view_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:html' as html;

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

  DeckBuild deck = DeckBuild.empty();
  SearchParameter searchParameter = SearchParameter();
  DigimonCard? selectCard;
  Timer? _debounce;

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
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () async {
      UserProvider().loginCheck();
      notes.addAll(await CardApi().getNotes());

      await TypeService().init();
      if (widget.searchParameterString != null) {
        searchParameter = SearchParameter.fromJson(
            json.decode(widget.searchParameterString!));
      }

      if (widget.deckView != null) {
        deck = DeckBuild.deckView(widget.deckView!, context);
        deck.saveMapToLocalStorage();
      } else if (widget.deck != null) {
        deck = widget.deck!;
        deck.saveMapToLocalStorage();
      } else {
        deck = DeckBuild(context);
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
                            }

                            setState(() {
                              isLoading = false;
                            });

                            Navigator.of(context).pop(true);
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
      });
    }
    if (widget.searchParameterString != null &&
        widget.searchParameterString != oldWidget.searchParameterString) {
      searchParameter =
          SearchParameter.fromJson(json.decode(widget.searchParameterString!));
      initSearch();
    }
  }

  void searchNote(int noteId) {
    searchParameter = SearchParameter();
    searchParameter.noteId = noteId;
    context.navigateTo(DeckBuilderRoute(
        searchParameterString: json.encode(searchParameter.toJson()),
        deck: widget.deck));

    initSearch();
  }

  initSearch() async {
    isSearchLoading = true;
    setState(() {});

    searchParameter.page = 1;
    CardResponseDto cardResponseDto =
        await CardApi().getCardsBySearchParameter(searchParameter);
    cards = cardResponseDto.cards!;
    totalPages = cardResponseDto.totalPages!;

    isSearchLoading = false;
    currentPage = searchParameter.page++;
    setState(() {});
  }

  addCardByDeck(DigimonCard card) {
    deck.addSingleCard(card);
    setState(() {});
  }

  removeCardByDeck(DigimonCard card) {
    deck.removeSingleCard(card);
    setState(() {});
  }

  Future<void> loadMoreCard() async {
    CardResponseDto cardResponseDto =
        await CardApi().getCardsBySearchParameter(searchParameter);
    cards.addAll(cardResponseDto.cards!);
    currentPage = searchParameter.page++;
  }

  deckUpdate(DeckView deckResponseDto) {
    deck.import(deckResponseDto);
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
            if (v > 0.1 && !_overlayRemoved) {
              _cardOverlayService.removeAllOverlays();
              _overlayRemoved = true;
            } else if (v <= 0.1) {
              _overlayRemoved = false;
            }
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
                                            searchNote: searchNote,
                                          )
                                        : CardScrollListView(
                                            cards: cards,
                                            loadMoreCards: loadMoreCard,
                                            cardPressEvent: addCardByDeck,
                                            totalPages: totalPages,
                                            currentPage: currentPage,
                                            searchNote: searchNote,
                                          ))
                                    : const Center(
                                        child: CircularProgressIndicator())),
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
                  DeckBuilderView(
                    deck: deck,
                    cardPressEvent: removeCardByDeck,
                    import: deckUpdate,
                    searchNote: searchNote,
                    cardOverlayService: _cardOverlayService,
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.17,
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
                  child: DeckBuilderView(
                    deck: deck,
                    cardPressEvent: removeCardByDeck,
                    import: deckUpdate,
                    searchNote: searchNote,
                    cardOverlayService: _cardOverlayService,
                  ),
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
                                      searchNote: searchNote,
                                    )
                                  : CardScrollListView(
                                      cards: cards,
                                      loadMoreCards: loadMoreCard,
                                      cardPressEvent: addCardByDeck,
                                      totalPages: totalPages,
                                      currentPage: currentPage,
                                      searchNote: searchNote,
                                    ))
                              : const Center(
                                  child: CircularProgressIndicator()))
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
