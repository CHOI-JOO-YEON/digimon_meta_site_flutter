import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

class CardScrollListView extends StatefulWidget {
  final List<DigimonCard> cards;
  final Future<void> Function() loadMoreCards;
  final Function(DigimonCard) cardPressEvent;
  final int totalPages;
  final int currentPage;
  final Function(DigimonCard)? mouseEnterEvent;

  const CardScrollListView(
      {super.key,
      required this.cards,
      required this.loadMoreCards,
      required this.cardPressEvent,
      this.mouseEnterEvent,
      required this.totalPages,
      required this.currentPage});

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

  OverlayEntry? _overlayEntry;

  void _showBigImage(BuildContext cardContext, String imgUrl) {
    final RenderBox renderBox = cardContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenWidth = MediaQuery.of(cardContext).size.width;
    final screenHeight = MediaQuery.of(cardContext).size.height;

    const double bigImageWidth = 300;
    const double bigImageHeight = 400;

    final double overlayLeft = 16;
    final double overlayTop = offset.dy;

    final double correctedTop = overlayTop < 0
        ? 0
        : overlayTop + bigImageHeight > screenHeight
            ? screenHeight - bigImageHeight
            : overlayTop;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: overlayLeft,
        top: correctedTop,
        width: bigImageWidth,
        height: bigImageHeight,
        child: Image.network(imgUrl, fit: BoxFit.cover),
      ),
    );

    Overlay.of(cardContext)?.insert(_overlayEntry!);
  }

  void _hideBigImage() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showImageDialog(BuildContext context, DigimonCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(card.imgUrl ?? '', fit: BoxFit.fill),
          actions: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                if (card.imgUrl != null) {
                  await WebImageDownloader.downloadImageFromWeb(
                    card.imgUrl!,
                    name: '${card.cardNo}_${card.cardName}.png',
                  );
                }
              },
              icon: Icon(Icons.download),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.cards.length + (isLoading ? 1 : 0),

      itemBuilder: (context, index) {
        if (index < widget.cards.length) {
          final card = widget.cards[index];
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                // border: Border.all(
                //   color: Colors.grey,
                //   width: 1.0,
                // ),
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[200]!
              ),
              child: ListTile(
                leading:Image.network(card.smallImgUrl!),
                title: Row(
                    children: [
                      Text('${card.cardNo} ${card.cardName}'),

                      if(card.lv!=null)
                      Text('\tLv.${card.lv==0?'-':card.lv}'),

                      Text('\t${card.rarity}',style: TextStyle(color: Colors.red),)
                    ],

                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.effect != null)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _buildEffectText(card.effect!, '상단 텍스트'),
                      ),
                    if (card.sourceEffect != null)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _buildEffectText(card.sourceEffect!, '하단 텍스트'),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () => _showImageDialog(context, card),
                ),
                onTap: () => widget.cardPressEvent(card),
              ),
            ),
          );
        } else {

          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildEffectText(String text, String prefix) {
    // 줄바꿈 후 시작하는 공백 제거
    final String trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');

    final List<InlineSpan> spans = [];
    final RegExp regexp = RegExp(r'(【[^【】]*】|《[^《》]*》|\[[^\[\]]*\]|〈[^〈〉]*〉)');
    final Iterable<Match> matches = regexp.allMatches(trimmedText);

    spans.add(TextSpan(text: prefix, style: TextStyle(fontWeight: FontWeight.bold)));
    spans.add(TextSpan(text: '\n')); // 줄바꿈 추가

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: trimmedText.substring(lastIndex, match.start)));
      }

      final String matchedText = match.group(0)!;
      final String innerText = matchedText.substring(1, matchedText.length - 1);
      Color backgroundColor;
      if (matchedText.startsWith('【') && matchedText.endsWith('】')) {
        backgroundColor = Color.fromRGBO(33, 37, 131, 1);
      } else if (matchedText.startsWith('《') && matchedText.endsWith('》')) {
        backgroundColor = Color.fromRGBO(206, 101, 1, 1);
      } else if (matchedText.startsWith('[') && matchedText.endsWith(']')) {
        backgroundColor = Color.fromRGBO(163, 23, 99, 1);
      } else if (matchedText.startsWith('〈') && matchedText.endsWith('〉')) {
        backgroundColor = Color.fromRGBO(206, 101, 1, 1);
      } else {
        backgroundColor = Colors.transparent;
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            margin: EdgeInsets.only(top: 2, bottom: 2),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              innerText,
              style: TextStyle(
                fontSize: 12,
                color: backgroundColor != Colors.transparent ? Colors.white : Colors.black,
                height: 1.6,
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
          height: 1.4,
          fontFamily: 'JalnanGothic',
        ),
      ),
    );
  }
}
