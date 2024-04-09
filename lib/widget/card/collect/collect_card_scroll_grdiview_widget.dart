import 'dart:math';

import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../provider/collect_provider.dart';
import '../card_widget.dart';

class CardScrollGridView extends StatefulWidget {
  final List<DigimonCard> cards;
  final int rowNumber;
  final Future<void> Function() loadMoreCards;
  final Function(DigimonCard) cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function(DigimonCard)? mouseEnterEvent;

  const CardScrollGridView({
    super.key,
    required this.cards,
    required this.rowNumber,
    required this.loadMoreCards,
    required this.cardPressEvent,
    this.mouseEnterEvent,
    required this.totalPages,
    required this.currentPage,
  });

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

    final bool onRightSide = (index % widget.rowNumber) < widget.rowNumber ~/ 2;
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
        child: Material(
          elevation: 8,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Consumer<CollectProvider>(
                      builder: (context, collectProvider, _) {
                        final quantity = collectProvider
                            .getCardQuantityById(widget.cards[index].cardId!);
                        return Text(
                          '수량: $quantity',
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final isPortrait =
        MediaQuery
            .of(context)
            .orientation == Orientation.portrait;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // double fontSize = min(constraints.maxWidth * 0.02,20);
        // double iconSize = min(constraints.maxWidth * 0.04,30);
        double fontSize= constraints.maxWidth*0.02;
        double iconSize= constraints.maxWidth*0.04;
        if(isPortrait){
          fontSize*=1.5;
          iconSize*=1.5;
        }

        return GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.rowNumber,
            crossAxisSpacing: constraints.maxWidth / 100,
            mainAxisSpacing: fontSize / 2,
            childAspectRatio: 0.5,
          ),
          itemCount: widget.cards.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < widget.cards.length) {
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    Consumer<CollectProvider>(
                      builder: (context, collectProvider, _) {
                        final quantity = collectProvider
                            .getCardQuantityById(widget.cards[index].cardId!);
                        return Column(
                          children: [
                            CustomCard(
                              card: widget.cards[index],
                              width: (constraints.maxWidth / widget.rowNumber) *
                                  0.99,
                              cardPressEvent: widget.cardPressEvent,
                              zoomActive: false,
                              onExit: _hideBigImage,
                              isActive: quantity > 0,
                            ),
                            SizedBox(
                              height: fontSize / 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: iconSize, height: iconSize),
                                  child: IconButton(
                                    onPressed: () {
                                      collectProvider.removeCard(
                                          widget.cards[index]);
                                    },
                                    padding: EdgeInsets.zero,
                                    iconSize: iconSize,
                                    icon: const Icon(Icons.remove),
                                  ),
                                ),
                                // SizedBox(
                                //   width: iconSize,
                                // ),

                                // ConstrainedBox(
                                //
                                //   constraints:
                                //       BoxConstraints.tightFor(height: iconSize),
                                //   child: Text(
                                //     '$quantity',
                                //     style: TextStyle(fontSize: fontSize),
                                //   ),
                                //
                                // ),
                                Text(
                                  '$quantity',
                                  style: TextStyle(fontSize: fontSize),
                                ),
                                // SizedBox(
                                //   width: iconSize,
                                // ),
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: iconSize, height: iconSize),
                                  child: IconButton(
                                    onPressed: () {
                                      collectProvider
                                          .addCard(widget.cards[index]);
                                    },
                                    padding: EdgeInsets.zero,
                                    iconSize: iconSize,
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
