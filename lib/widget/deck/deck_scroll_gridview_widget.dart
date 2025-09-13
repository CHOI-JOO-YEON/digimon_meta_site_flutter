import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stroke_text/stroke_text.dart';

import '../../model/card.dart';
import '../../model/search_parameter.dart';
import '../../provider/locale_provider.dart';
import '../../service/card_overlay_service.dart';
import '../../service/card_service.dart';
import '../card/card_widget.dart';

class DeckScrollGridView extends StatefulWidget {
  final Map<DigimonCard, int> deckCount;
  final List<DigimonCard> deck;
  final int rowNumber;
  final Function(SearchParameter)? searchWithParameter;
  final Function(DigimonCard)? addCard;
  final Function(DigimonCard)? removeCard;
  final CardOverlayService cardOverlayService;
  final bool isTama;
  final Function(double)? onCardSizeCalculated;

  const DeckScrollGridView({
    super.key,
    required this.deckCount,
    required this.rowNumber,
    required this.deck,
    this.searchWithParameter,
    this.addCard,
    this.removeCard,
    required this.cardOverlayService,
    required this.isTama,
    this.onCardSizeCalculated,
  });

  @override
  State<DeckScrollGridView> createState() => _DeckScrollGridViewState();
}

class _DeckScrollGridViewState extends State<DeckScrollGridView>
    with WidgetsBindingObserver {
  Size _lastSize = Size.zero;
  String? _activeCardId; // 현재 증감 모드가 활성화된 카드 ID

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this); // Observer 등록
    _scrollController.addListener(() {
      // 큰 이미지 미리보기만 숨김
      widget.cardOverlayService.hideBigImage();
    });
  }

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _cardKeys = {};

  // 활성화된 카드 전환 메서드
  void _setActiveCard(String? cardId) {
    setState(() {
      _activeCardId = cardId;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(DeckScrollGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rowNumber != widget.rowNumber) {
      // 큰 이미지 미리보기만 숨김
      widget.cardOverlayService.hideBigImage();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final Size newSize = MediaQuery.sizeOf(context);

    if (newSize != _lastSize) {
      // 큰 이미지 미리보기만 숨김
      widget.cardOverlayService.hideBigImage();
      
      _lastSize = newSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 카드 크기 계산 및 부모에게 전달
        final cardWidth = (constraints.maxWidth / widget.rowNumber) * 0.99;
        if (widget.onCardSizeCalculated != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onCardSizeCalculated!(cardWidth);
          });
        }
        
        return GridView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.rowNumber,
            childAspectRatio: 0.715,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 12.0,
          ),
          itemCount: widget.deck.length,
          itemBuilder: (context, index) {
            DigimonCard card = widget.deck[index];
            int count = widget.deckCount[card]!;

            String cardId = card.cardId?.toString() ?? 'card_$index';
            _cardKeys.putIfAbsent(cardId, () => GlobalKey());
            GlobalKey cardKey = _cardKeys[cardId]!;

            // 이 카드가 활성화되었는지 확인
            bool isActiveCard = _activeCardId == cardId;

            return AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: 1.0,
              child: CustomCard(
                key: cardKey,
                card: card,
                width: (constraints.maxWidth / widget.rowNumber) * 0.99,
                onLongPress: () => CardService().showImageDialog(
                  context,
                  card,
                  searchWithParameter: widget.searchWithParameter
                ),
                onHover: (ctx) {
                  final RenderBox renderBox = ctx.findRenderObject() as RenderBox;
                  final localeProvider = Provider.of<LocaleProvider>(ctx, listen: false);
                  widget.cardOverlayService.showBigImage(
                    ctx,
                    card.getDisplayImgUrl(localeProvider.localePriority) ?? '',
                    renderBox,
                    widget.rowNumber,
                    index,
                    card: card,
                  );
                },
                onExit: () => widget.cardOverlayService.hideBigImage(),
                searchWithParameter: widget.searchWithParameter,
                hoverEffect: true,
                addCard: widget.addCard,
                removeCard: widget.removeCard,
                cardCount: count,
                isButtonsActive: isActiveCard,
                onButtonsToggle: (isActive) {
                  // 버튼이 활성화되면 이 카드 ID를 활성화된 카드로 설정
                  // 버튼이 비활성화되면 null로 설정
                  _setActiveCard(isActive ? cardId : null);
                },
              ),
            );
          },
        );
      },
    );
  }
}
