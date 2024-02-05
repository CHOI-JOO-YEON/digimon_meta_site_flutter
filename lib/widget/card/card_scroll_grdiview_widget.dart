import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/material.dart';

import 'card_widget.dart';

class CardScrollGridView extends StatefulWidget {
  final List<DigimonCard> cards;
  final int rowNumber;
  final VoidCallback loadMoreCards;
  final Function(DigimonCard) cardPressEvent;
  final int totalPages;
  final Function(DigimonCard)? mouseEnterEvent;

  const CardScrollGridView(
      {super.key, required this.cards, required this.rowNumber, required this.loadMoreCards, required this.cardPressEvent, this.mouseEnterEvent, required this.totalPages});


  @override
  State<CardScrollGridView> createState() => _CardScrollGridViewState();
}

class _CardScrollGridViewState extends State<CardScrollGridView> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent && !isLoading) {
        // 스크롤이 끝에 도달했을 때
        loadMoreItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void loadMoreItems() {
    isLoading= true;
    setState(() {

    });
    Future.delayed(Duration(seconds: 0), () {
      widget.loadMoreCards();
      setState(() {
        // widget.cards.addAll(List.generate(20, (index) => 'Item ${items.length + index}'));
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GridView.builder(
            controller: _scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.rowNumber,
              // crossAxisSpacing: constraints.maxWidth / 50,
              // mainAxisSpacing: constraints.maxHeight / 50,
              childAspectRatio: 0.73,
            ),
            itemCount: widget.cards.length + (isLoading ? 1 : 0),
            // 로딩 인디케이터를 위한 공간
            itemBuilder: (context, index) {
              if (index < widget.cards.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomCard(card: widget.cards[index],
                    width: (constraints.maxWidth / widget.rowNumber) * 0.8,
                    cardPressEvent: widget.cardPressEvent,
                    mouseEnterEvent: widget.mouseEnterEvent,

                  ),
                );
              } else {
                return const Center(
                    child: CircularProgressIndicator()); // 로딩 인디케이터
              }
            },
          );
        }
    );
  }
}
