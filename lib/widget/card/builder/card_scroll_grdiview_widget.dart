import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:flutter/material.dart';

import '../../../service/card_overlay_service.dart';
import '../../../service/card_service.dart';
import '../card_widget.dart';

class CardScrollGridView extends StatefulWidget {
  final List<DigimonCard> cards;
  final int rowNumber;
  final VoidCallback? loadMoreCards;
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
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
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
    setState(() => isLoading = true);
    if (widget.loadMoreCards != null) {
      widget.loadMoreCards!();
    }
    setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.rowNumber,
          crossAxisSpacing: constraints.maxWidth / 100,
          mainAxisSpacing: constraints.maxWidth / 100,
          childAspectRatio: 0.715,
        ),
        itemCount: widget.cards.length + (isLoading ? 1 : 0),
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
                onHover: (ctx) {
                  final RenderBox renderBox = ctx.findRenderObject() as RenderBox;
                  _cardOverlayService.showBigImage(
                    ctx, 
                    card.getDisplayImgUrl()!, 
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    });
  }
}
