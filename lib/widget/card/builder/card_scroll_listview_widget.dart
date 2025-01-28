import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:digimon_meta_site_flutter/service/color_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../provider/text_simplify_provider.dart';
import '../../../service/size_service.dart';

class CardScrollListView extends StatefulWidget {
  final List<DigimonCard> cards;
  final Future<void> Function() loadMoreCards;
  final Function(DigimonCard) cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function(DigimonCard)? mouseEnterEvent;
  final Function(int)? searchNote;

  const CardScrollListView({
    super.key,
    required this.cards,
    required this.loadMoreCards,
    required this.cardPressEvent,
    this.mouseEnterEvent,
    required this.totalPages,
    required this.currentPage,
    this.searchNote,
  });

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
        Consumer<TextSimplifyProvider>(
          builder: (context, textSimplifyProvider, child) {
            return Row(
              children: [
                Text('텍스트 간소화'),
                Transform.scale(
                  scale: SizeService.switchScale(context),
                  child: Switch(
                    value: textSimplifyProvider.getTextSimplify(),
                    onChanged: (v) =>
                        textSimplifyProvider.updateTextSimplify(v),
                    inactiveThumbColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.cards.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < widget.cards.length) {
                final card = widget.cards[index];
                return Padding(
                  padding: EdgeInsets.all(SizeService.paddingSize(context)),
                  child: GestureDetector(
                    onTap: () => widget.cardPressEvent(card),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            SizeService.roundRadius(context)),
                        color: Colors.grey[300],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(SizeService.paddingSize(context)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 4,
                                child: GestureDetector(
                                  onTap: () => CardService().showImageDialog(
                                    context,
                                    card,
                                    widget.searchNote,
                                  ),
                                  child: Image.network(
                                    card.getDisplaySmallImgUrl()!,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image);
                                    },
                                  ),
                                )),
                            Expanded(flex: 1, child: Container(),),
                            Expanded(
                                flex: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${card.cardNo} ${card.getDisplayName()}',
                                      style: TextStyle(
                                        fontFamily:
                                            card.getDisplayLocale() == 'JPN'
                                                ? "MPLUSC"
                                                : "JalnanGothic",
                                      ),
                                    ),
                                    if (card.getDisplayEffect() != null)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(top: 4),
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: EffectText(
                                                text: card.getDisplayEffect()!,
                                                prefix: '상단 텍스트',
                                                locale: card.getDisplayLocale()!,
                                              ),
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
                                                color: Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: EffectText(
                                                text: card
                                                    .getDisplaySourceEffect()!,
                                                prefix: '하단 텍스트',
                                                locale: card.getDisplayLocale()!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}

class EffectText extends StatelessWidget {
  final String text;
  final String prefix;
  final String locale;

  const EffectText({
    Key? key,
    required this.text,
    required this.prefix,
    required this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTextSimplify =
        Provider.of<TextSimplifyProvider>(context).getTextSimplify();
    final List<InlineSpan> spans = [];
    spans.add(TextSpan(
      text: prefix,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: "JalnanGothic",
      ),
    ));
    spans.add(const TextSpan(text: '\n'));
    spans.addAll(CardService().getSpansByLocale(locale, text, isTextSimplify));

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
          height: 1.4,
          fontFamily: locale == 'JPN' ? "MPLUSC" : "JalnanGothic",
        ),
      ),
    );
  }
}
