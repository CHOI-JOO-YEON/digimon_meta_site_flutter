import 'dart:math';

import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/deck/color_palette.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_bar.dart';
import 'package:flutter/material.dart';

import '../../../model/deck_response_dto.dart';
import '../../../model/format.dart';

class DeckListViewer extends StatefulWidget {
  final List<FormatDto> formatList;
  final Function(DeckResponseDto) deckUpdate;

  const DeckListViewer(
      {super.key, required this.formatList, required this.deckUpdate});

  @override
  State<DeckListViewer> createState() => _DeckListViewerState();
}

class _DeckListViewerState extends State<DeckListViewer> {
  DeckSearchParameter deckSearchParameter =
      DeckSearchParameter(isMyDeck: false);
  List<DeckResponseDto> decks = [];
  int currentPage = 1;
  int maxPage = 0;
  int _selectedIndex = -1;

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
        _selectedIndex = 0;
      });
      widget.deckUpdate(decks.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width*0.009,15);
    if(isPortrait) {
      fontSize*=2;
    }
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: ListView.builder(
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                return ListTile(
                  leading: ColorWheel(
                    colors: deck.colors!,
                  ),
                  selected: index == _selectedIndex,
                  title: Text(
                    deck.deckName ?? '',
                      style: TextStyle(fontSize: fontSize)
                  ),
                  subtitle: Text(
                    '작성자: ${deck.authorName}',
                      style: TextStyle(fontSize: fontSize)
                  ),
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
