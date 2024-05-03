import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

import '../model/card.dart';
import 'color_service.dart';

class CardService {
  void showImageDialog(BuildContext context, DigimonCard card,
      Function(int)? searchNote) {
    final isPortrait =
        MediaQuery
            .of(context)
            .orientation == Orientation.portrait;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: isPortrait
                ? MediaQuery
                .of(context)
                .size
                .width * 0.8
                : MediaQuery
                .of(context)
                .size
                .width * 0.3,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Text(
                            '${card.cardNo}',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme
                                    .of(context)
                                    .hintColor),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${card.rarity}',
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme
                                    .of(context)
                                    .primaryColor),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${card.getKorCardType()}',
                            style: TextStyle(
                                fontSize: 18,
                                color: ColorService.getColorFromString(
                                    card.color1!)),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          if (card.lv != null)
                            ElevatedButton(

                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Theme
                                      .of(context)
                                      .cardColor,
                                  disabledForegroundColor: Colors.black
                              ),
                              child: Text(
                                'Lv.${card.lv}',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${card.cardName}',
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Stack(
                                  children: [
                                    Image.network(card.imgUrl ?? '',
                                        fit: BoxFit.fill),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: IconButton(
                                          padding: EdgeInsets.zero,
                                          tooltip: '이미지 다운로드',
                                          onPressed: () async {
                                            if (card.imgUrl != null) {
                                              await WebImageDownloader
                                                  .downloadImageFromWeb(card.imgUrl!,
                                                  name:
                                                  '${card.cardNo}_${card
                                                      .cardName}.png');
                                            }
                                          },
                                          icon: Icon(Icons.download,color: Theme.of(context).primaryColor,
                                          )),
                                    ),
                                  ],
                                ),

                              ],
                            )),
                        Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                _attributeWidget(
                                    context, [card.getKorForm()!], '형태',
                                    ColorService.getColorFromString(
                                        card.color1!)),
                                if(card.attributes != null)
                                  _attributeWidget(
                                      context, [card.attributes!], '속성',
                                      ColorService.getColorFromString(
                                          card.color1!)),
                                if(card.types != null)
                                  _attributeWidget(context, card.types!, '유형',
                                      ColorService.getColorFromString(
                                          card.color1!)),
                              ],
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (card.effect != null)
                      _effectWidget(context, card.effect!, '상단 텍스트',
                          ColorService.getColorFromString(card.color1!)),
                    SizedBox(
                      height: 5,
                    ),
                    if (card.sourceEffect != null)
                      _effectWidget(context, card.sourceEffect!, '하단 텍스트',
                          ColorService.getColorFromString(card.color1!)),
                    SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        if (searchNote != null) {
                          Navigator.pop(context);
                          searchNote(card.noteId!)!;

                        }

                      },


                      child: Row(
                        children: [
                          Text(
                            '입수 정보: ${card.noteName}',
                            style: TextStyle(color: Colors.black),
                          ),

                        ],
                      ),
                    )

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _effectWidget(BuildContext context, String text, String category,
      Color categoryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme
              .of(context)
              .splashColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category,
              style: TextStyle(color: categoryColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildEffectText(text),
          )
        ],
      ),
    );
  }

  Widget _attributeWidget(BuildContext context, List<String> attributes,
      String category, Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme
                .of(context)
                .splashColor,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category,
                style: TextStyle(color: categoryColor),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: attributes.map((attribute) =>
                        Chip(label: Text(attribute),

                        )).toList()
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEffectText(String text) {
    // 줄바꿈 후 시작하는 공백 제거
    final String trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');

    final List<InlineSpan> spans = [];
    final RegExp regexp = RegExp(
        r'(【[^【】]*】|《[^《》]*》|\[[^\[\]]*\]|〈[^〈〉]*〉|\([^()]*\)|〔[^〔〕]*〕)');
    final Iterable<Match> matches = regexp.allMatches(trimmedText);

    spans
        .add(TextSpan(text: '', style: TextStyle(fontWeight: FontWeight.bold)));

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans
            .add(TextSpan(text: trimmedText.substring(lastIndex, match.start)));
      }

      final String matchedText = match.group(0)!;
      String innerText = matchedText.substring(1, matchedText.length - 1);
      Color backgroundColor;
      if (matchedText.startsWith('【') && matchedText.endsWith('】')) {
        backgroundColor = Color.fromRGBO(33, 37, 131, 1);
      } else if (matchedText.startsWith('《') && matchedText.endsWith('》')) {
        backgroundColor = Color.fromRGBO(206, 101, 1, 1);
      } else if (matchedText.startsWith('[') && matchedText.endsWith(']')) {
        backgroundColor = Color.fromRGBO(163, 23, 99, 1);
      } else if (matchedText.startsWith('〔') && matchedText.endsWith('〕')) {
        backgroundColor = Color.fromRGBO(163, 23, 99, 1);
      } else if (matchedText.startsWith('〈') && matchedText.endsWith('〉')) {
        backgroundColor = Color.fromRGBO(206, 101, 1, 1);
      } else if (matchedText.startsWith('(') && matchedText.endsWith(')')) {
        innerText = '(' + innerText + ')';
        backgroundColor = Colors.transparent;
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
                color: backgroundColor != Colors.transparent
                    ? Colors.white
                    : Colors.black,
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