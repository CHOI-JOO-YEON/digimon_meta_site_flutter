
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/enhanced_pagination.dart';
import 'package:digimon_meta_site_flutter/widget/deck/color_palette.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_bar.dart';
import 'package:flutter/material.dart';

import '../../../model/deck-view.dart';
import '../../../model/format.dart';
import '../../../service/size_service.dart';
import '../../../widget/common/toast_overlay.dart' show ToastOverlay, ToastType;

class MyDeckListViewer extends StatefulWidget {
  final List<FormatDto> formatList;
  final FormatDto selectedFormat;
  final Function(DeckView) deckUpdate;
  final Function(FormatDto) updateSelectFormat;
  final DeckSearchParameter deckSearchParameter;
  final VoidCallback updateSearchParameter;

  const MyDeckListViewer(
      {super.key,
      required this.formatList,
      required this.deckUpdate,
      required this.selectedFormat,
      required this.updateSelectFormat,
      required this.deckSearchParameter,
      required this.updateSearchParameter});

  @override
  State<MyDeckListViewer> createState() => _MyDeckListViewerState();
}

class _MyDeckListViewerState extends State<MyDeckListViewer> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  List<DeckView> decks = [];
  int currentPage = 1;
  int maxPage = 0;
  int totalResults = 0;
  int _selectedIndex = -1;
  bool isLoading = false;
  CancelToken? _cancelToken;
  DeckView? _currentSelectedDeck; // 현재 선택된 덱 저장
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    widget.deckSearchParameter.formatId = widget.selectedFormat.formatId;

    Future.delayed(const Duration(seconds: 0), () async {
      await searchDecks(widget.deckSearchParameter.myPage);
    });
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 진행 중인 API 요청 취소
    _cancelToken?.cancel('위젯이 dispose됨');
    _scrollController.dispose(); // 스크롤 컨트롤러 dispose
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
    widget.deckSearchParameter.isMyDeck = true;
    currentPage = page;
    widget.deckSearchParameter.updatePage(page, true);
    
    // 페이지 변경 시 스크롤을 맨 위로 이동
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    try {
      PagedResponseDeckDto? pagedDeck =
          await DeckService().getDeck(widget.deckSearchParameter, context, cancelToken: _cancelToken);
      
      // 요청이 취소되지 않았을 때만 결과 처리
      if (!(_cancelToken?.isCancelled ?? true)) {
        if (pagedDeck != null) {
          decks = pagedDeck.decks;
          maxPage = pagedDeck.totalPages;
          totalResults = pagedDeck.totalElements;
          
          // 이전에 선택된 덱이 있으면 찾아서 유지
          if (_currentSelectedDeck != null) {
            int foundIndex = decks.indexWhere((deck) => deck.deckId == _currentSelectedDeck!.deckId);
            if (foundIndex != -1) {
              _selectedIndex = foundIndex;
            } else {
              // 이전 선택 덱이 목록에 없으면 첫 번째 선택
              _selectedIndex = decks.isNotEmpty ? 0 : -1;
              if (decks.isNotEmpty) {
                _currentSelectedDeck = decks.first;
                widget.deckUpdate(decks.first);
              }
            }
          } else {
            // 처음 로드 시
            _selectedIndex = decks.isNotEmpty ? 0 : -1;
            if (decks.isNotEmpty) {
              _currentSelectedDeck = decks.first;
              widget.deckUpdate(decks.first);
            }
          }
        }
        
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // DioException의 cancel 에러는 정상적인 취소 상황이므로 무시
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

  void deleteDeck(int deckId) async {
    bool isSuccess = await DeckService().deleteDeckAndRefreshCounts(deckId, context);
    if (isSuccess) {
      ToastOverlay.show(
        context,
        '덱이 삭제되었습니다.',
        type: ToastType.success
      );
      
      if (decks.length == 1) {
        await searchDecks(1);
      } else {
        await searchDecks(widget.deckSearchParameter.myPage);
      }
    }
  }

  void showModifyConfirmationDialog(BuildContext context, DeckView deck) {
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
                DeckBuild newDeck = DeckBuild.deckView(deck, context);
                newDeck.isSave = true;
                context.navigateTo(DeckBuilderRoute(deck: newDeck));
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
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    return Column(
      children: [
        DeckSearchBar(
          formatList: widget.formatList,
          searchParameter: widget.deckSearchParameter,
          search: searchDecks,
          selectedFormat: widget.selectedFormat,
          updateSelectFormat: widget.updateSelectFormat,
          isMyDeck: true,
          totalResults: totalResults > 0 ? totalResults : null,
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '덱을 검색 중입니다...',
                                  style: TextStyle(
                                    fontSize: SizeService.bodyFontSize(context),
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : decks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '검색 결과가 없습니다',
                                      style: TextStyle(
                                        fontSize: SizeService.bodyFontSize(context) * 1.2,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '다른 검색 조건을 시도해보세요',
                                      style: TextStyle(
                                        fontSize: SizeService.bodyFontSize(context),
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController, // 스크롤 컨트롤러 연결
                                itemCount: decks.length,
                                padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: MediaQuery.orientationOf(context) == Orientation.portrait 
                                    ? MediaQuery.sizeOf(context).height * 0.7 // 세로 모드에서 바텀시트를 위한 추가 패딩
                                    : 8,
                                  left: 4,
                                  right: 4,
                                ),
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                cacheExtent: 500.0, // 캐시 확장으로 스크롤 성능 개선
                                itemBuilder: (context, index) {
                                  final deck = decks[index];
                                  final isSelected = index == _selectedIndex;
                                  
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Theme.of(context).primaryColor.withOpacity(0.1),
                                                Theme.of(context).primaryColor.withOpacity(0.05),
                                              ],
                                            )
                                          : null,
                                      color: isSelected ? null : const Color(0xFFFAFAFA), // 선택되지 않은 경우 약간 회색빛 배경
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                                              width: 2,
                                            )
                                          : Border.all(
                                              color: Colors.grey.withOpacity(0.1),
                                              width: 1,
                                            ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Theme.of(context).primaryColor.withOpacity(0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.02),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                    ),
                                    child: ListTile(
                                      leading: ColorWheel(
                                        colors: deck.colors!,
                                      ),
                                      selected: isSelected,
                                      selectedTileColor: Colors.transparent, // 기본 선택 색상 제거
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: Text(
                                        deck.deckName ?? '',
                                        style: TextStyle(
                                          fontSize: SizeService.bodyFontSize(context),
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: isSelected 
                                              ? Theme.of(context).primaryColor 
                                              : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${deck.authorName}#${(deck.authorId! - 3).toString().padLeft(4, '0')}',
                                        style: TextStyle(
                                          fontSize: SizeService.smallFontSize(context),
                                          color: isSelected 
                                              ? Theme.of(context).primaryColor.withOpacity(0.8)
                                              : null,
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: SizeService.mediumIconSize(context) * 5,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                size: SizeService.mediumIconSize(context),
                                                color: isSelected 
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey[600],
                                              ),
                                              tooltip: '덱 수정',
                                              onPressed: () {
                                                showModifyConfirmationDialog(context, deck);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                size: SizeService.mediumIconSize(context),
                                                color: isSelected 
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey[600],
                                              ),
                                              tooltip: '덱 삭제',
                                              onPressed: () {
                                                showDeleteConfirmationDialog(context, deck.deckId!);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedIndex = index;
                                          _currentSelectedDeck = decks[index];
                                        });
                                        widget.deckUpdate(decks[index]);
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ),
              // 페이지네이션을 별도 영역으로 분리하여 항상 표시
              const SizedBox(height: 8),
              EnhancedPagination(
                currentPage: currentPage,
                totalPages: maxPage,
                onPageChanged: searchDecks,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
