import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/format.dart';
import 'package:digimon_meta_site_flutter/provider/collect_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../api/card_api.dart';
import '../model/card.dart';
import '../model/card_search_response_dto.dart';
import '../model/note.dart';
import '../model/search_parameter.dart';
import '../provider/user_provider.dart';
import '../router.dart';
import '../service/deck_service.dart';
import '../widget/card/builder/card_search_bar.dart';
import '../widget/card/collect/collect_card_scroll_grdiview_widget.dart';
import '../widget/card/collect/deck_calc_dialog.dart';

@RoutePage()
class CollectPage extends StatefulWidget {
  const CollectPage({super.key});

  @override
  State<CollectPage> createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  final ScrollController _scrollController = ScrollController();
  List<DigimonCard> cards = [];
  bool isSearchLoading = true;
  List<NoteDto> notes = [];
  List<FormatDto> formats = [];
  int totalPages = 0;
  int currentPage = 0;

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

    Future.delayed(const Duration(seconds: 0), () async {
      bool isLogin = await UserProvider().loginCheck();
      if (!isLogin) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('로그인 필요'),
              content: const Text('로그인이 필요한 페이지입니다. 로그인 후 이용해주세요.'),
              actions: [
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    // 확인 버튼을 누르면 deck-builder 페이지로 이동
                    Navigator.of(context).pop();
                    context.navigateTo(DeckBuilderRoute());
                  },
                ),
              ],
            );
          },
        );
        return;
      }
      notes.add(NoteDto(noteId: null, name: '모든 카드'));
      notes.addAll(await CardApi().getNotes());
      formats = await DeckService().getAllFormat();
      if (formats.isEmpty) {
        formats.add(new FormatDto(
            formatId: 1,
            name: '테스트',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            isOnlyEn: false));
      }

      setState(() {});
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

  void _showSaveCollectDialog(BuildContext context, bool isSave) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(isSave ? '저장 성공' : '저장 실패'),
          ],
        ));
      },
    );
  }

  void _showCalcDialog(BuildContext context, List<DeckResponseDto> decks) {
    Map<int, List<DeckResponseDto>> deckMap = {};

    for (var deck in decks) {
      if (deckMap[deck.formatId] == null) {
        deckMap[deck.formatId!] = [];
      }
      deckMap[deck.formatId]!.add(deck);
    }


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DeckCalcDialog(formats: formats,deckMap: deckMap,);
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Row(
      children: [
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: isPortrait ? 20 : 5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        List<DeckResponseDto>? decks =
                            await DeckApi().findAllMyDecks();
                        if (decks != null && decks.isNotEmpty) {
                          _showCalcDialog(context, decks);
                        }
                      },
                      child: const Text('필요한 카드 계산')),
                  SizedBox(width: 10,),
                  ElevatedButton(
                      onPressed: () async {
                        CollectProvider p = Provider.of(context, listen: false);
                        bool isSave = await p.save();
                        _showSaveCollectDialog(context, isSave);
                        setState(() {});
                      },
                      child: const Text('저장')),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: Container(
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
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                Expanded(
                                    flex: 9,
                                    child: !isSearchLoading
                                        ? CardScrollGridView(
                                            cards: cards,
                                            rowNumber: isPortrait ? 6 : 8,
                                            loadMoreCards: loadMoreCard,
                                            cardPressEvent: (card) {},
                                            totalPages: totalPages,
                                            currentPage: currentPage,
                                          )
                                        : const Center(
                                            child:
                                                CircularProgressIndicator())),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }
}
