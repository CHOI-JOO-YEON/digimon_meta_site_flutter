import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/material.dart';

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
      required this.currentPage, this.searchNote});

  @override
  State<CardScrollGridView> createState() => _CardScrollGridViewState();
}

class _CardScrollGridViewState extends State<CardScrollGridView> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

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

  OverlayEntry? _overlayEntry;

  void _showBigImage(BuildContext cardContext, String imgUrl, int index) {
    final RenderBox renderBox = cardContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(cardContext).size.height;
    final screenWidth = MediaQuery.of(cardContext).size.width;

    final bool onRightSide = (index % 6) < 3;
    final double overlayLeft = onRightSide
        ? offset.dx + renderBox.size.width
        : offset.dx - renderBox.size.width * 3;

    final double overlayTop =
        (offset.dy + renderBox.size.height * 3 > screenHeight)
            ? screenHeight - renderBox.size.height * 3
            : offset.dy;

    final double correctedLeft = overlayLeft < 0 ? 0 : overlayLeft;

    final double correctedWidth =
        correctedLeft + renderBox.size.width * 3 > screenWidth
            ? screenWidth - correctedLeft
            : renderBox.size.width * 3;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: correctedLeft,
        top: overlayTop,
        width: correctedWidth,
        height: renderBox.size.height * 3,
        child: Image.network(imgUrl, fit: BoxFit.cover),
      ),
    );

    Overlay.of(cardContext)?.insert(_overlayEntry!);
  }

  void _hideBigImage() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
                onHover: (context) =>
                    _showBigImage(context, widget.cards[index].imgUrl!, index),
                onExit: _hideBigImage,
                searchNote: widget.searchNote,
                onDoubleTab: () => CardService().showImageDialog(
                  context,widget.cards[index], widget.searchNote),
                onLongPress: widget.cardPressEvent,
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
