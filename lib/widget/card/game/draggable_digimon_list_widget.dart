import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/card.dart';
import '../../../state/game_state.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class DraggableDigimonListWidget extends StatefulWidget {
  final String id;
  final double cardWidth;
  final List<Widget> children;
  final double height;

  const DraggableDigimonListWidget({
    super.key,
    required this.id,
    required this.children,
    required this.cardWidth,
    required this.height,
  });

  @override
  State<DraggableDigimonListWidget> createState() =>
      _DraggableDigimonListWidgetState();
}

class _DraggableDigimonListWidgetState
    extends State<DraggableDigimonListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final PageController pageController = PageController();
  double _availableWidth = 0;
  int currentPageIndex = 0;

  // 한 페이지에 들어갈 카드 수 계산
  int get cardsPerPage {
    if (widget.children.isEmpty || _availableWidth <= 0) return 1;
    
    // 화살표 버튼 너비를 고려한 실제 사용 가능한 너비
    double contentWidth = _availableWidth - 70; // 좌우 버튼 여백 고려
    int maxCards = (contentWidth / widget.cardWidth).floor();
    return maxCards.clamp(1, widget.children.length);
  }

  // 총 페이지 수 계산
  int get totalPages {
    if (widget.children.isEmpty || cardsPerPage <= 0) return 1;
    return ((widget.children.length - 1) / cardsPerPage).floor() + 1;
  }

  // 페이지별 카드 리스트 생성
  List<List<Widget>> get pageCards {
    if (widget.children.isEmpty) return [];
    
    List<List<Widget>> pages = [];
    for (int i = 0; i < widget.children.length; i += cardsPerPage) {
      int endIndex = (i + cardsPerPage).clamp(0, widget.children.length);
      pages.add(widget.children.sublist(i, endIndex));
    }
    return pages;
  }

  // 이전 페이지로 이동
  void _goToPreviousPage() {
    if (currentPageIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // 다음 페이지로 이동
  void _goToNextPage() {
    if (currentPageIndex < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return DragTarget<MoveCard>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) {
        MoveCard? move = details.data;
        move.toId = widget.id;

        List<DigimonCard> cards = gameState.getCardsBySourceId(
            move.fromId, move.fromStartIndex, move.fromEndIndex);

        if (cards.isEmpty) {
          return;
        }

        final RenderBox box = context.findRenderObject() as RenderBox;
        final double localX = box.globalToLocal(details.offset).dx;
        
        // 현재 페이지의 카드들 중에서 위치 계산
        int cardsInCurrentPage = pageCards.isNotEmpty && currentPageIndex < pageCards.length 
            ? pageCards[currentPageIndex].length 
            : 0;
        
        // 페이지 내에서의 인덱스 계산
        int indexInPage = ((localX + widget.cardWidth / 2) / widget.cardWidth).floor();
        indexInPage = indexInPage.clamp(0, cardsInCurrentPage);
        
        // 전체 리스트에서의 실제 인덱스 계산
        int globalIndex = (currentPageIndex * cardsPerPage) + indexInPage;
        move.toStartIndex = globalIndex.clamp(0, widget.children.length);

        gameState.moveCards(move, cards, true);
      },
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 실제 사용 가능한 너비 저장
            _availableWidth = constraints.maxWidth;
            
            List<List<Widget>> pages = pageCards;
            
            return SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  // 페이지 뷰
                  Positioned.fill(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentPageIndex = index;
                        });
                      },
                      itemBuilder: (context, pageIndex) {
                        // 현재 페이지의 카드들을 가져옴
                        List<Widget> currentPageCards = pages[pageIndex];
                        
                        // 최대 카드 수만큼 위젯 리스트 생성 (빈 공간은 Spacer로 채움)
                        List<Widget> paddedCards = [];
                        for (int i = 0; i < cardsPerPage; i++) {
                          if (i < currentPageCards.length) {
                            paddedCards.add(currentPageCards[i]);
                          } else {
                            paddedCards.add(SizedBox(width: widget.cardWidth)); // 빈 공간
                          }
                        }
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 35), // 버튼 공간 확보
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: paddedCards,
                          ),
                        );
                      },
                    ),
                  ),
                  // 좌측 스크롤 버튼 (이전 페이지)
                  if (pages.isNotEmpty && totalPages > 1)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.grey[100]!,
                              Colors.grey[100]!.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: currentPageIndex > 0 ? Colors.white : Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: currentPageIndex > 0 ? Colors.grey[700] : Colors.grey[500],
                                size: 24,
                              ),
                              onPressed: currentPageIndex > 0 ? _goToPreviousPage : null,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 우측 스크롤 버튼 (다음 페이지)
                  if (pages.isNotEmpty && totalPages > 1)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.grey[100]!,
                              Colors.grey[100]!.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: currentPageIndex < totalPages - 1 ? Colors.white : Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: currentPageIndex < totalPages - 1 ? Colors.grey[700] : Colors.grey[500],
                                size: 24,
                              ),
                              onPressed: currentPageIndex < totalPages - 1 ? _goToNextPage : null,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 페이지 인디케이터
                  if (pages.isNotEmpty && totalPages > 1)
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${currentPageIndex + 1} / $totalPages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
