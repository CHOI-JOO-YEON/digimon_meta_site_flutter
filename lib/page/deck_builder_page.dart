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
  bool isSearchLoading = true;
  List<DigimonCard> cards = [];
  List<NoteDto> notes = [];
  int totalPages = 0;
  int currentPage = 0;

  Deck deck = Deck();
  SearchParameter searchParameter = SearchParameter();
  DigimonCard? selectCard;

  @override
  void initState() {
    super.initState();
    if(widget.deck!=null) {
      deck = widget.deck!;
    }
    Future.delayed(const Duration(seconds: 0), () async {
      UserProvider().loginCheck();
      notes.add(NoteDto(noteId: null, name: '모든 카드'));
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
                  color: Colors.blueAccent),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.88,
                  // height: 1000,
                  child: DeckBuilderView(
                    deck: deck,
                    // mouseEnterEvent: changeViewCardInfo,
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
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(5),
                      // border: Border.all()
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.sizeOf(context).width * 0.01),
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
