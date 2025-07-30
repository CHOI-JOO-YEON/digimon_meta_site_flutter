import 'dart:math';

import 'package:dio/dio.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/enhanced_pagination.dart';
import 'package:digimon_meta_site_flutter/widget/deck/color_palette.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_bar.dart';
import 'package:flutter/material.dart';

import '../../../model/deck-view.dart';
import '../../../model/format.dart';

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
  int totalResults = 0;
  int _selectedIndex = -1;
  bool isLoading = false;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    widget.deckSearchParameter.formatId = widget.selectedFormat.formatId;
    Future.delayed(const Duration(seconds: 0), () async {
      await searchDecks(widget.deckSearchParameter.allPage);
    });
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 진행 중인 API 요청 취소
    _cancelToken?.cancel('위젯이 dispose됨');
    super.dispose();
  }

  Future<void> searchDecks(int page) async {
    if (isLoading) {
      return;
    }

    // 이전 요청이 있다면 취소
    _cancelToken?.cancel('새로운 검색 요청');
    
    // 새로운 CancelToken 생성
    _cancelToken = CancelToken();

    isLoading = true;
    widget.deckSearchParameter.isMyDeck = false;
    currentPage = page;
    widget.deckSearchParameter.updatePage(page, false);
    
    try {
      PagedResponseDeckDto? pagedDeck =
          await DeckService().getDeck(widget.deckSearchParameter, context, cancelToken: _cancelToken);
      
      // 요청이 취소되지 않았을 때만 결과 처리
      if (!(_cancelToken?.isCancelled ?? true)) {
        if (pagedDeck != null) {
          decks = pagedDeck.decks;
          maxPage = pagedDeck.totalPages;
          totalResults = pagedDeck.totalElements;
          _selectedIndex = 0;

          if (decks.isNotEmpty) {
            widget.deckUpdate(decks.first);
          }
        }
        
        if (mounted) {
          setState(() {
            widget.updateSearchParameter();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // DioException의 cancel 에러는 정상적인 치소 상황이므로 무시
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      
      // 다른 에러의 경우 로딩 상태 해제
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DeckSearchBar(
          formatList: widget.formatList,
          searchParameter: widget.deckSearchParameter,
          search: searchDecks,
          selectedFormat: widget.selectedFormat,
          updateSelectFormat: widget.updateSelectFormat,
          isMyDeck: false,
          totalResults: totalResults > 0 ? totalResults : null,
        ),
        const SizedBox(
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
                      style: TextStyle(
                          fontSize: SizeService.bodyFontSize(context))),
                  subtitle: Text(
                    '${deck.authorName}#${(deck.authorId! - 3).toString().padLeft(4, '0')}',
                    style: TextStyle(
                      fontSize: SizeService.smallFontSize(context)
                    )
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
        EnhancedPagination(
          currentPage: currentPage,
          totalPages: maxPage,
          onPageChanged: searchDecks,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
