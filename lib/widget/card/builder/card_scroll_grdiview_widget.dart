import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/locale_provider.dart';
import '../../../service/card_overlay_service.dart';
import '../../../service/card_service.dart';
import '../card_widget.dart';

class CardScrollGridView extends StatefulWidget {
  final List<DigimonCard> cards;
  final int rowNumber;
  final Future<void> Function()? loadMoreCards; // Changed to return Future
  final Function(DigimonCard)? cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function(SearchParameter)? searchWithParameter;

  const CardScrollGridView({
    super.key,
    required this.cards,
    required this.rowNumber,
    this.loadMoreCards,
    this.cardPressEvent,
    required this.totalPages,
    required this.currentPage,
    this.searchWithParameter,
  });

  @override
  State<CardScrollGridView> createState() => _CardScrollGridViewState();
}

class _CardScrollGridViewState extends State<CardScrollGridView> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  final CardOverlayService _cardOverlayService = CardOverlayService();
  final Map<int, bool> _cardAddingEffects = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // 스크롤이 끝에서 200px 정도 남았을 때 미리 로딩 시작
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        widget.currentPage < widget.totalPages) {
      loadMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadMoreItems() async {
    if (isLoading || widget.loadMoreCards == null) return;
    
    setState(() => isLoading = true);
    
    try {
      await widget.loadMoreCards!(); // 실제 로딩 완료까지 기다림
    } catch (e) {
      // 에러 처리
      debugPrint('Error loading more cards: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _playAdditionEffect(DigimonCard card) {
    if (card.cardId == null) return;
    
    setState(() {
      _cardAddingEffects[card.cardId!] = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _cardAddingEffects.remove(card.cardId);
        });
      }
    });
  }

  void _handleCardAddition(DigimonCard card) {
    _playAdditionEffect(card);
    if (widget.cardPressEvent != null) {
      widget.cardPressEvent!(card);
    }
  }

  Widget _buildLoadingIndicator(BoxConstraints constraints) {
    return Container(
      height: (constraints.maxWidth / widget.rowNumber) * 1.4, // 카드와 비슷한 높이
      margin: EdgeInsets.all(constraints.maxWidth / 100),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '로딩 중...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'JalnanGothic',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // 세로 모드에서 바텀시트를 위한 추가 패딩 계산
      final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
      final screenHeight = MediaQuery.sizeOf(context).height;
      final additionalPadding = isPortrait ? screenHeight * 0.7 : 0.0; // 바텀시트 최대 크기만큼 여유 패딩
      
      return GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: additionalPadding), // 하단 패딩 추가
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.rowNumber,
          crossAxisSpacing: constraints.maxWidth / 100,
          mainAxisSpacing: constraints.maxWidth / 100,
          childAspectRatio: 0.715,
        ),
        itemCount: widget.cards.length + (isLoading ? widget.rowNumber : 0), // 한 줄 전체에 로딩 표시
        itemBuilder: (context, index) {
          if (index < widget.cards.length) {
            final card = widget.cards[index];
            final bool isAddingCard = card.cardId != null && (_cardAddingEffects[card.cardId!] ?? false);
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              transform: isAddingCard 
                  ? (Matrix4.identity()..scale(1.02))
                  : Matrix4.identity(),
              padding: const EdgeInsets.all(0),
              decoration: isAddingCard
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 5,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        )
                      ],
                    )
                  : null,
              child: CustomCard(
                card: card,
                width: (constraints.maxWidth / widget.rowNumber) * 0.99,
                cardPressEvent: (card) => _handleCardAddition(card),
                searchWithParameter: widget.searchWithParameter,
                onHover: (ctx) {
                  final RenderBox renderBox = ctx.findRenderObject() as RenderBox;
                  final localeProvider = Provider.of<LocaleProvider>(ctx, listen: false);
                  _cardOverlayService.showBigImage(
                    ctx, 
                    card.getDisplayImgUrl(localeProvider.localePriority) ?? '', 
                    renderBox, 
                    widget.rowNumber, 
                    index
                  );
                },
                onExit: () => _cardOverlayService.hideBigImage(),
                onLongPress: () => CardService().showImageDialog(
                    context, card, searchWithParameter: widget.searchWithParameter),
              ),
            );
          } else {
            // 로딩 인디케이터들
            return _buildLoadingIndicator(constraints);
          }
        },
      );
    });
  }
}
