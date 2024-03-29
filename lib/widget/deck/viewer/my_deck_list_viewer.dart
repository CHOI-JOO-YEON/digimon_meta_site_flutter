import 'dart:math';

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
  final FormatDto selectedFormat;
  final Function(DeckResponseDto) deckUpdate;
  final Function(FormatDto) updateSelectFormat;
  const MyDeckListViewer(
      {super.key, required this.formatList, required this.deckUpdate, required this.selectedFormat, required this.updateSelectFormat});

  @override
  State<MyDeckListViewer> createState() => _MyDeckListViewerState();
}

class _MyDeckListViewerState extends State<MyDeckListViewer> {
  DeckSearchParameter deckSearchParameter = DeckSearchParameter(isMyDeck: true);
  List<DeckResponseDto> decks = [];
  int currentPage = 1;
  int maxPage = 0;
  int _selectedIndex = -1;
  bool isLoading= false;
  @override
  void initState() {
    super.initState();
    deckSearchParameter.formatId = widget.selectedFormat.formatId;



    Future.delayed(const Duration(seconds: 0), () async {
      await searchDecks(1);
    });
  }

  Future<void> searchDecks(int page) async {
    if(isLoading) {
      return;
    }

    isLoading =true;

    currentPage = page;
    deckSearchParameter.updatePage(page);
    PagedResponseDeckDto? pagedDeck = await DeckService().getDeck(deckSearchParameter,context);


    if (pagedDeck != null) {
      decks = pagedDeck.decks;

      maxPage = pagedDeck.totalPages;
      _selectedIndex = 0;

      if(!decks.isEmpty) {
        widget.deckUpdate(decks.first);
      }

    }
    setState(() {
      isLoading =false;
    });



  }



  void deleteDeck(int deckId) async {
    bool isSuccess = await DeckService().deleteDeck(deckId);
    if (isSuccess) {
      if(decks.length==1) {
        await searchDecks(1);
      }else{
        await searchDecks(deckSearchParameter.page);
      }

    }
  }

  void showModifyConfirmationDialog(
      BuildContext context, DeckResponseDto deck) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('덱 수정'),
          content: Text('이 덱을 수정하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('수정'),
              onPressed: () {
                Navigator.of(context).pop();
                context.navigateTo(DeckBuilderRoute(deck: Deck.responseDto(deck)));
              },
            ),
          ],
        );
      },
    );
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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.009, 15);
    if (isPortrait) {
      fontSize *= 2;
    }
    return Column(
      children: [
        DeckSearchBar(
          formatList: widget.formatList,
          searchParameter: deckSearchParameter,
          search: searchDecks,
          selectedFormat:  widget.selectedFormat, updateSelectFormat: widget.updateSelectFormat,
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
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
                          onPressed: () {
                            showModifyConfirmationDialog(context, deck);
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
                  leading: ColorWheel(
                    colors: deck.colors!,
                  ),
                  selected: index == _selectedIndex,
                  title: Text(
                    deck.deckName ?? '',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  subtitle: Text('작성자: ${deck.authorName}',
                      style: TextStyle(fontSize: fontSize)),
                  // 덱 아이템을 탭했을 때의 동작 처리
                  onTap: () {
                    _selectedIndex = index;
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
            Text('Page $currentPage of $maxPage',
                style: TextStyle(fontSize: fontSize)),
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
