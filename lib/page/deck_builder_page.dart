import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/type.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/service/type_service.dart';
import 'package:digimon_meta_site_flutter/widget/card/builder/card_scroll_grdiview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/card/builder/card_scroll_listview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:html' as html;

import '../model/card.dart';
import '../model/note.dart';
import '../widget/card/builder/card_search_bar.dart';

@RoutePage()
class DeckBuilderPage extends StatefulWidget {
  final String? searchParameterString;
  final Deck? deck;

  const DeckBuilderPage({super.key, this.deck,@QueryParam('searchParameter') this.searchParameterString});

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  bool init = true;
  String viewMode = 'grid';
  final ScrollController _scrollController = ScrollController();
  final PanelController _panelController = PanelController();
  bool isSearchLoading = true;
  List<DigimonCard> cards = [];
  List<NoteDto> notes = [];
  int totalPages = 0;
  int currentPage = 0;
  bool isTextSimplify = true;


  Deck deck = Deck();
  SearchParameter searchParameter = SearchParameter();
  DigimonCard? selectCard;

  void updateSearchParameter()
  {
    AutoRouter.of(context).navigate(
      DeckBuilderRoute(searchParameterString: json.encode(searchParameter.toJson()),deck: widget.deck),
    );
  }
  void onViewModeChanged(String newMode) {
    viewMode = newMode;
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () async {
      UserProvider().loginCheck();
      notes.addAll(await CardApi().getNotes());
      List<TypeDto> types = await CardApi().getTypes();
      for (var type in types) {
        TypeService().insert(type);
      }
      if (widget.searchParameterString != null) {
        searchParameter = SearchParameter.fromJson(json.decode(widget.searchParameterString!));
      }

      if (widget.deck != null) {
        deck = widget.deck!;
        deck.saveMapToLocalStorage();
      } else {
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
                    title: Text('저장된 덱 불러오기'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('이전에 작성 중이던 덱이 있습니다. 불러오시겠습니까?'),
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    actions: [
                      if (!isLoading)
                        TextButton(
                          child: Text('아니오'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            html.window.localStorage.remove('deck');
                          },
                        ),
                      if (!isLoading)
                        TextButton(
                          child: Text('예'),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            Deck? savedDeck = await DeckService()
                                .createDeckByLocalJsonString(deckJsonString);
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
  }

  @override
  void didUpdateWidget(covariant DeckBuilderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deck != oldWidget.deck) {
      setState(() {
        deck = widget.deck ?? Deck();
      });
    }
    if(widget.searchParameterString!=null&& widget.searchParameterString!=oldWidget.searchParameterString) {
      searchParameter = SearchParameter.fromJson(json.decode(widget.searchParameterString!));
      initSearch();
    }
  }

  void searchNote(int noteId) {
    searchParameter = SearchParameter();
    searchParameter.noteId = noteId;
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
    deck.addCard(card, context);
    setState(() {});
  }

  removeCardByDeck(DigimonCard card) {
    deck.removeCard(card);
    setState(() {});
  }

  Future<void> loadMoreCard() async {
    CardResponseDto cardResponseDto =
        await CardApi().getCardsBySearchParameter(searchParameter);
    cards.addAll(cardResponseDto.cards!);
    currentPage = searchParameter.page++;
  }

  searchMethod(SearchParameter searchParameter) {
    this.searchParameter = searchParameter;
    loadMoreCard();
  }

  deckUpdate(DeckResponseDto deckResponseDto) {
    deck.import(deckResponseDto);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.009, 15);
    if (isPortrait) {
      fontSize *= 2;
      if (init) {
        viewMode = "list";
      }
    }
    init = false;

    if (isPortrait) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SlidingUpPanel(
          controller: _panelController,
          renderPanelSheet: false,
          minHeight: 50,
          snapPoint: 0.5,
          maxHeight: constraints.maxHeight,
          isDraggable: false,
          panelBuilder: (ScrollController sc) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.sizeOf(context).width * 0.01,
                    right: MediaQuery.sizeOf(context).width * 0.01,
                    bottom: MediaQuery.sizeOf(context).width * 0.01),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                              flex: 1,
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
                                        fontSize: fontSize,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        _scrollController.animateTo(
                                          0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Text(
                                        '메인덱 보기',
                                        style: TextStyle(fontSize: fontSize),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Text(
                                        '타마덱 보기',
                                        style: TextStyle(fontSize: fontSize),
                                      ))
                                ],
                              ))
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            SizedBox(
                                height: 50,
                                // flex: 1,
                                child: CardSearchBar(
                                  notes: notes,
                                  searchParameter: searchParameter,
                                  onSearch: initSearch,
                                  viewMode: viewMode,
                                  onViewModeChanged: onViewModeChanged, updateSearchParameter: updateSearchParameter,
                                )),
                            SizedBox(
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
                                            // mouseEnterEvent: changeViewCardInfo,
                                            totalPages: totalPages,
                                            currentPage: currentPage,
                                            searchNote: searchNote,
                                          )
                                        : CardScrollListView(
                                            cards: cards,
                                            loadMoreCards: loadMoreCard,
                                            cardPressEvent: addCardByDeck,
                                            // mouseEnterEvent: changeViewCardInfo,
                                            totalPages: totalPages,
                                            currentPage: currentPage,
                                            updateIsTextSimplify: (v) {
                                              isTextSimplify = v;
                                              setState(() {});
                                            },
                                            isTextSimplify: isTextSimplify,
                                            searchNote: searchNote,
                                          ))
                                    : Center(
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
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.88,
                    child: DeckBuilderView(
                      deck: deck,
                      cardPressEvent: removeCardByDeck,
                      import: deckUpdate,
                      searchNote: searchNote,

                    ),
                  ),
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                  ),
                ],
              ),
            ),
          ),
        );
      });
    } else {
      return Padding(
        padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).highlightColor),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.88,
                    child: DeckBuilderView(
                      deck: deck,
                      cardPressEvent: removeCardByDeck,
                      import: deckUpdate,
                      searchNote: searchNote,
                    ),
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
                  borderRadius: BorderRadius.circular(5),
                  // border: Border.all()
                ),
                child: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.01),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child: CardSearchBar(
                            notes: notes,
                            searchParameter: searchParameter,
                            onSearch: initSearch,
                            viewMode: viewMode,
                            onViewModeChanged: onViewModeChanged, updateSearchParameter: updateSearchParameter,
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
                                      updateIsTextSimplify: (v) {
                                        isTextSimplify = v;
                                        setState(() {});
                                      },
                                      isTextSimplify: isTextSimplify,
                                      searchNote: searchNote,
                                    ))
                              : Center(child: CircularProgressIndicator()))
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
