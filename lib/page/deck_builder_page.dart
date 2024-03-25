import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/card_search_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/widget/card/card_scroll_grdiview_widget.dart';
import 'package:digimon_meta_site_flutter/widget/deck/builder/deck_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


import '../model/card.dart';
import '../model/note.dart';
import '../widget/card/card_search_bar.dart';

@RoutePage()
class DeckBuilderPage extends StatefulWidget {
  final Deck? deck;

  const DeckBuilderPage({super.key, this.deck});

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  final ScrollController _scrollController = ScrollController();
  final PanelController _panelController = PanelController();
  bool isSearchLoading = true;
  List<DigimonCard> cards = [];
  List<NoteDto> notes = [];
  int totalPages = 0;
  int currentPage = 0;

  Deck deck = Deck();
  SearchParameter searchParameter = SearchParameter();
  DigimonCard? selectCard;

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
    if (widget.deck != null) {
      deck = widget.deck!;
    }
    Future.delayed(const Duration(seconds: 0), () async {
      UserProvider().loginCheck();
      // notes.add(NoteDto(noteId: null, name: '모든 카드'));
      notes.addAll(await CardApi().getNotes());

      initSearch();
    });
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
    deck.addCard(card);
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
    }
    if (isPortrait) {
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SlidingUpPanel(
          controller: _panelController,
          renderPanelSheet: false,
          minHeight: 50,
          maxHeight: constraints.maxHeight/2,
          isDraggable: false,
          panel: Container(
            margin:  EdgeInsets.only(
                left: MediaQuery.sizeOf(context).width * 0.01,
                right: MediaQuery.sizeOf(context).width * 0.01,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)
              )
            ),
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
                          child: GestureDetector(
                            onTap: (){
                              if(_panelController.isPanelOpen){
                                _panelController.close();
                              }else{
                                _panelController.open();
                              }
                              setState(() {

                              });
                            },
                            child: Transform.scale(
                              scaleX: 2,
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
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
                      child: Column(children: [
                        SizedBox(
                            height: 50,
                            // flex: 1,
                            child: CardSearchBar(
                              notes: notes,
                              searchParameter: searchParameter,
                              onSearch: initSearch,
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          // flex: 9,
                            child: !isSearchLoading
                                ? CardScrollGridView(
                              cards: cards,
                              rowNumber: 6,
                              loadMoreCards: loadMoreCard,
                              cardPressEvent: addCardByDeck,
                              totalPages: totalPages,
                              currentPage: currentPage,
                            )
                                : Center(child: CircularProgressIndicator())),
                      ],)),

                ],
              ),
            ),
          ),

          body: Padding(
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
                    // height: 1000,
                    child: DeckBuilderView(
                      deck: deck,
                      // mouseEnterEvent: ,
                      cardPressEvent: removeCardByDeck,
                      import: deckUpdate,
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
                          )),
                      Expanded(
                          flex: 9,
                          child: !isSearchLoading
                              ? CardScrollGridView(
                                  cards: cards,
                                  rowNumber: 6,
                                  loadMoreCards: loadMoreCard,
                                  cardPressEvent: addCardByDeck,
                                  // mouseEnterEvent: changeViewCardInfo,
                                  totalPages: totalPages,
                                  currentPage: currentPage,
                                )
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
