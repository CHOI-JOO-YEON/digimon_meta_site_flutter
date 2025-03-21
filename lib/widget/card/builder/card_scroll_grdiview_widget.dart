import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/material.dart';

import '../../../service/card_overlay_service.dart';
import '../../../service/card_service.dart';
import '../card_widget.dart';

class CardScrollGridView extends StatefulWidget {
  final List<DigimonCard> cards;
  final int rowNumber;
  final Future<void> Function() loadMoreCards;
  final Function(DigimonCard) cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(int)? searchNote;

  const CardScrollGridView(
      {super.key,
      required this.cards,
      required this.rowNumber,
      required this.loadMoreCards,
      required this.cardPressEvent,
      this.mouseEnterEvent,
      required this.totalPages,
      required this.currentPage,
      this.searchNote,});

  @override
  State<CardScrollGridView> createState() => _CardScrollGridViewState();
}

class _CardScrollGridViewState extends State<CardScrollGridView> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  final CardOverlayService _cardOverlayService = CardOverlayService();

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
    await widget.loadMoreCards();
    setState(() => isLoading = false);
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
            return Padding(
              padding: const EdgeInsets.all(0),
              child: CustomCard(
                card: widget.cards[index],
                width: (constraints.maxWidth / widget.rowNumber) * 0.99,
                cardPressEvent: widget.cardPressEvent,
                onHover: (ctx) {
                  final RenderBox renderBox = ctx.findRenderObject() as RenderBox;
                  _cardOverlayService.showBigImage(
                    ctx, 
                    widget.cards[index].getDisplayImgUrl()!, 
                    renderBox, 
                    widget.rowNumber, 
                    index
                  );
                },
                onExit: () => _cardOverlayService.hideBigImage(),
                searchNote: widget.searchNote,
                onLongPress: () => CardService().showImageDialog(
                    context, widget.cards[index], widget.searchNote),
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
