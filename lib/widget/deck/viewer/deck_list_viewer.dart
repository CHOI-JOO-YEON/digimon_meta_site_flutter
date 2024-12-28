import 'dart:math';

import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/deck/color_palette.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/deck-view.dart';
import '../../../model/format.dart';
import '../../../provider/format_deck_count_provider.dart';

class DeckListViewer extends StatefulWidget {
  final List<FormatDto> formatList;
  final FormatDto selectedFormat;
  final Function(DeckView) deckUpdate;
  final Function(FormatDto) updateSelectFormat;
  final DeckSearchParameter deckSearchParameter;
  final VoidCallback updateSearchParameter;

  const DeckListViewer(
      {super.key,
      required this.formatList,
      required this.deckUpdate,
      required this.selectedFormat,
      required this.updateSelectFormat,
      required this.deckSearchParameter,
      required this.updateSearchParameter});

  @override
  State<DeckListViewer> createState() => _DeckListViewerState();
}

class _DeckListViewerState extends State<DeckListViewer> {
  List<DeckView> decks = [];
  int currentPage = 1;
  int maxPage = 0;
  int _selectedIndex = -1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.deckSearchParameter.formatId = widget.selectedFormat.formatId;
    Future.delayed(const Duration(seconds: 0), () async {
      await searchDecks(widget.deckSearchParameter.allPage);
    });
  }

  Future<void> searchDecks(int page) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    widget.deckSearchParameter.isMyDeck = false;
    currentPage = page;
    widget.deckSearchParameter.updatePage(page, false);
    PagedResponseDeckDto? pagedDeck =
        await DeckService().getDeck(widget.deckSearchParameter, context);
    if (pagedDeck != null) {
      FormatDeckCountProvider formatDeckCountProvider = Provider.of(context, listen: false);
      formatDeckCountProvider.setFormatAllDeckCount(pagedDeck);
      decks = pagedDeck.decks;

      maxPage = pagedDeck.totalPages;
      _selectedIndex = 0;

      if (!decks.isEmpty) {
        widget.deckUpdate(decks.first);
      }
    }
    setState(() {
      widget.updateSearchParameter();
      isLoading = false;
    });
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
          searchParameter: widget.deckSearchParameter,
          search: searchDecks,
          selectedFormat: widget.selectedFormat,
          updateSelectFormat: widget.updateSelectFormat,
          isMyDeck: false,
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
                  title: Text(deck.deckName ?? '',
                      style: TextStyle(fontSize: fontSize)),
                  subtitle: Text(
                      '${deck.authorName}#${(deck.authorId! - 3).toString().padLeft(4, '0')}',
                      style: TextStyle(fontSize: fontSize * 0.8)),
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
