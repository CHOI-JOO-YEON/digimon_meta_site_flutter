import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:digimon_meta_site_flutter/service/color_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardScrollListView extends StatefulWidget {
  final List<DigimonCard> cards;
  final Future<void> Function() loadMoreCards;
  final Function(DigimonCard) cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function(DigimonCard)? mouseEnterEvent;
  final bool isTextSimplify;
  final Function(bool) updateIsTextSimplify;
  final Function(int)? searchNote;

  const CardScrollListView(
      {super.key,
      required this.cards,
      required this.loadMoreCards,
      required this.cardPressEvent,
      this.mouseEnterEvent,
      required this.totalPages,
      required this.currentPage,
      required this.isTextSimplify,
      required this.updateIsTextSimplify,
      this.searchNote});

  @override
  State<CardScrollListView> createState() => _CardScrollListViewState();
}

class _CardScrollListViewState extends State<CardScrollListView> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('텍스트 간소화'),
            Switch(
              value: widget.isTextSimplify,
              onChanged: (v) => widget.updateIsTextSimplify(v),
              inactiveThumbColor: Colors.red,
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.cards.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < widget.cards.length) {
                final card = widget.cards[index];
                Color color = ColorService.getColorFromString(card.color1!);
                if (color == Colors.white) {
                  color = Colors.grey;
                }
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).cardColor),
                    child: ListTile(
                      leading: Image.network(card.getDisplaySmallImgUrl()!),
                      title: Row(
                        children: [
                          Text('${card.cardNo}'),
                          Text(
                            ' ${card.getDisplayName()}',
                            style: TextStyle(
                                fontFamily: card.getDisplayLocale() == 'JPN'
                                    ? "MPLUSC"
                                    : "JalnanGothic"),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (card.getDisplayEffect() != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _buildEffectText(
                                        card.getDisplayEffect()!,
                                        '상단 텍스트',
                                        card.getDisplayLocale()!),
                                  ),
                                ),
                              ],
                            ),
                          if (card.getDisplaySourceEffect() != null)
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _buildEffectText(
                                        card.getDisplaySourceEffect()!,
                                        '하단 텍스트',
                                        card.getDisplayLocale()!),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.zoom_in),
                        onPressed: () => CardService()
                            .showImageDialog(context, card, widget.searchNote),
                      ),
                      onTap: () => widget.cardPressEvent(card),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildEffectText(String text, String prefix, String locale) {
    final List<InlineSpan> spans = [];
    spans.add(TextSpan(
        text: prefix,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontFamily: "JalnanGothic")));
    spans.add(const TextSpan(text: '\n'));

    if(widget.isTextSimplify) {
      final RegExp pattern1 = RegExp(r'（[^（）]*）');
      final RegExp pattern2 = RegExp(r'\([^()]*\)');
      text = text.replaceAll(pattern1, "");
      text = text.replaceAll(pattern2, "");
    }
    spans.addAll(CardService().getSpansByLocale(locale, text));

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            height: 1.4,
            fontFamily: locale == 'JPN' ? "MPLUSC" : "JalnanGothic"),
      ),
    );
  }
}
