import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/deck.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/deck/color_palette.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_bar.dart';
import 'package:flutter/material.dart';

import '../../../model/deck_response_dto.dart';
import '../../../model/format.dart';

class MyDeckListViewer extends StatefulWidget {
  final List<FormatDto> formatList;
  final Function(DeckResponseDto) deckUpdate;

  const MyDeckListViewer(
      {super.key, required this.formatList, required this.deckUpdate});

  @override
  State<MyDeckListViewer> createState() => _MyDeckListViewerState();
}

class _MyDeckListViewerState extends State<MyDeckListViewer> {
  DeckSearchParameter deckSearchParameter = DeckSearchParameter(isMyDeck: true);
  List<DeckResponseDto> decks = [];
  int currentPage = 1;
  int maxPage = 0;
  int _selectedIndex=-1;
  @override
  void initState() {
    super.initState();
    deckSearchParameter.formatId = widget.formatList.first.formatId;
    Future.delayed(const Duration(seconds: 0), () async {
      await searchDecks(1);
    });
  }

  Future<void> searchDecks(int page) async {
    setState(() {
      currentPage = page;
    });
    deckSearchParameter.updatePage(page);
    PagedResponseDeckDto? pagedDeck =
        await DeckService().getDeck(deckSearchParameter);
    if (pagedDeck != null) {
      setState(() {

        decks = pagedDeck.decks;
        maxPage = pagedDeck.totalPages;
        _selectedIndex=0;
      });
      widget.deckUpdate(decks.first);

    }
  }

  void deleteDeck(int deckId) async{
    bool isSuccess = await DeckService().deleteDeck(deckId);
    if (isSuccess) {
      // 삭제가 성공한 경우에만 위젯을 다시 로딩
      await searchDecks(1);
    }
  }
  void showDeleteConfirmationDialog(BuildContext context, int deckId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('덱 삭제'),
          content: Text('정말로 이 덱을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteDeck(deckId);
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DeckSearchBar(
          formatList: widget.formatList,
          searchParameter: deckSearchParameter,
          search: searchDecks,
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5)),
            child: ListView.builder(
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                return ListTile(
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.mode),
                          onPressed: (){
                            context.router.push(DeckBuilderRoute(deck: Deck.responseDto(decks[index])));
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDeleteConfirmationDialog(context, deck.deckId!);
                          },
                        ),
                      ],
                    ),
                  ),
                  leading: ColorWheel(colors: deck.colors!,),
                  selected: index == _selectedIndex,
                  title: Text(deck.deckName ?? ''),
                  subtitle: Text('작성자: ${deck.authorName}'),
                  // 덱 아이템을 탭했을 때의 동작 처리
                  onTap: () {
                    _selectedIndex=index;
                    widget.deckUpdate(decks[index]);
                  },
                );
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentPage > 1
                  ? () {
                      searchDecks(currentPage - 1);
                    }
                  : null,
            ),
            Text('Page $currentPage of $maxPage'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentPage < maxPage
                  ? () {
                      searchDecks(currentPage + 1);
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
