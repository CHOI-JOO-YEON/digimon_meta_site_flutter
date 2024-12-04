import 'dart:math';

import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/use_card_response_dto.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import '../model/card.dart';
import '../model/locale_card_data.dart';
import 'color_service.dart';

class CardService {
  void showImageDialog(
      BuildContext context, DigimonCard card, Function(int)? searchNote) {
    CardOverlayService cardOverlayService = CardOverlayService();
    cardOverlayService.removeAllOverlays();
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = min(screenWidth * 0.03, 15.0);
    bool showUsedCards = false;
    UseCardResponseDto useCardResponseDto =
    UseCardResponseDto(usedCardList: [], totalCount: 0, initialize: false);

    int selectedLocaleIndex = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              LocaleCardData localeCardData = card.localeCardDatas[selectedLocaleIndex];

              return AlertDialog(
                content: Stack(
                  children: [
                    Column(
                      children: [
                        if (showUsedCards) ...[
                          Text(
                            '같이 채용된 카드',
                            style: TextStyle(
                              fontSize: fontSize * 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '총 ${useCardResponseDto.totalCount}개의 덱에서 이 카드가 사용되었습니다.',
                            style: TextStyle(fontSize: fontSize),
                          ),
                          SizedBox(height: 10),
                        ],
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              width: isPortrait
                                  ? screenWidth * 0.8
                                  : screenWidth * 0.3,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!showUsedCards) ...[
                                    Container(
                                      width: double.infinity,
                                      child: Wrap(
                                        crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                        spacing: 10,
                                        children: [
                                          Text(
                                            '${card.cardNo}',
                                            style: TextStyle(
                                                fontSize: fontSize,
                                                color:
                                                Theme.of(context).hintColor),
                                          ),
                                          Text(
                                            '${card.rarity}',
                                            style: TextStyle(
                                                fontSize: fontSize,
                                                color:
                                                Theme.of(context).primaryColor),
                                          ),
                                          Text(
                                            '${card.getKorCardType()}',
                                            style: TextStyle(
                                                fontSize: fontSize,
                                                color:
                                                ColorService.getColorFromString(
                                                    card.color1!)),
                                          ),
                                          if (card.lv != null)
                                            ElevatedButton(
                                              onPressed: null,
                                              style: ElevatedButton.styleFrom(
                                                disabledBackgroundColor:
                                                Theme.of(context).cardColor,
                                                disabledForegroundColor:
                                                Colors.black,
                                              ),
                                              child: Text(
                                                'Lv.${card.lv}',
                                                style: TextStyle(fontSize: fontSize),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: card.localeCardDatas.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        LocaleCardData localeCardDate = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedLocaleIndex = index;
                                              });
                                            },
                                            child: Text(
                                              localeCardDate.locale,
                                              style: TextStyle(
                                                fontSize: fontSize * 0.8,
                                                color: selectedLocaleIndex == index
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey,
                                                fontWeight: selectedLocaleIndex == index
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          localeCardData?.name ?? '데이터 없음',
                                          style:
                                          TextStyle(fontSize: fontSize * 1.2,
                                            fontFamily: localeCardData.locale=='JPN'?"MPLUSC":"JalnanGothic"
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            children: [
                                              LayoutBuilder(builder:
                                                  (BuildContext context,
                                                  BoxConstraints constraints) {
                                                return SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: Stack(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                        constraints.maxWidth,
                                                        child: Image.network(
                                                            card.imgUrl ?? '',
                                                            fit: BoxFit.fitWidth),
                                                      ),
                                                      Positioned(
                                                        right: 0,
                                                        bottom: 0,
                                                        child: Container(
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Theme.of(context)
                                                                .canvasColor,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: IconButton(
                                                            padding:
                                                            EdgeInsets.zero,
                                                            tooltip: '이미지 다운로드',
                                                            onPressed: () async {
                                                              if (card.imgUrl !=
                                                                  null) {
                                                                await WebImageDownloader
                                                                    .downloadImageFromWeb(
                                                                  card.imgUrl!,
                                                                  name:
                                                                  '${card.cardNo}_${card.getDisplayName()}.png',
                                                                );
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.download,
                                                              color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                              size: fontSize * 1.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                        if (!isPortrait)
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              children: [
                                                if (card.form != null)
                                                  _attributeWidget(
                                                      context,
                                                      [card.getKorForm()],
                                                      '형태',
                                                      ColorService
                                                          .getColorFromString(
                                                          card.color1!),
                                                      fontSize),
                                                if (card.attributes != null)
                                                  _attributeWidget(
                                                      context,
                                                      [card.attributes!],
                                                      '속성',
                                                      ColorService
                                                          .getColorFromString(
                                                          card.color1!),
                                                      fontSize),
                                                if (card.types != null &&
                                                    card.types!.isNotEmpty)
                                                  _attributeWidget(
                                                      context,
                                                      card.types!,
                                                      '유형',
                                                      ColorService
                                                          .getColorFromString(
                                                          card.color1!),
                                                      fontSize),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (isPortrait)
                                      Wrap(
                                        children: [
                                          if (card.form != null)
                                            _attributeWidget(
                                                context,
                                                [card.getKorForm()],
                                                '형태',
                                                ColorService.getColorFromString(
                                                    card.color1!),
                                                fontSize),
                                          if (card.attributes != null)
                                            _attributeWidget(
                                                context,
                                                [card.attributes!],
                                                '속성',
                                                ColorService.getColorFromString(
                                                    card.color1!),
                                                fontSize),
                                          if (card.types != null &&
                                              card.types!.isNotEmpty)
                                            _attributeWidget(
                                                context,
                                                card.types!,
                                                '유형',
                                                ColorService.getColorFromString(
                                                    card.color1!),
                                                fontSize),
                                        ],
                                      ),
                                    const SizedBox(height: 5),
                                    if (localeCardData.effect != null)
                                      _effectWidget(
                                          context,
                                          localeCardData.effect!,
                                          '상단 텍스트',
                                          ColorService.getColorFromString(
                                              card.color1!),
                                          fontSize, localeCardData.locale),
                                    const SizedBox(height: 5),
                                    if (localeCardData.sourceEffect != null)
                                      _effectWidget(
                                          context,
                                          localeCardData.sourceEffect!,
                                          '하단 텍스트',
                                          ColorService.getColorFromString(
                                              card.color1!),
                                          fontSize, localeCardData.locale),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: InkWell(
                                        onTap: () {
                                          if (searchNote != null) {
                                            Navigator.pop(context);
                                            searchNote(card.noteId!)!;
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Wrap(
                                            children: [
                                              Text(
                                                '입수 정보: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                card.noteName!,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: fontSize,
                                                ),
                                                maxLines: null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    // 같이 사용된 카드 목록 표시

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                      useCardResponseDto.usedCardList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final usedCardInfo =
                                        useCardResponseDto
                                            .usedCardList[index];
                                        final usedCard = usedCardInfo.card;
                                        return Container(
                                          margin: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(5)),
                                          child: ListTile(
                                            leading: Image.network(
                                                usedCard.smallImgUrl ?? ''),
                                            title: Text(
                                              usedCard.getDisplayName() ?? '',
                                              style: TextStyle(
                                                  color: getColor(
                                                      usedCardInfo.ratio)),
                                            ),
                                            subtitle: Text(
                                                '덱: ${usedCardInfo.count}, 비율: ${(usedCardInfo.ratio * 100).toStringAsFixed(0)}%'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              showImageDialog(
                                                  context, usedCard, searchNote);
                                            },
                                            trailing: Text(
                                              '${usedCardInfo.rank}위',
                                              style:
                                              TextStyle(fontSize: fontSize),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            showUsedCards = !showUsedCards;
                            if (showUsedCards) {
                              if (!useCardResponseDto.initialize) {
                                useCardResponseDto =
                                await CardApi().getUseCard(card.cardId!);
                              }
                            }
                            setState(() {});
                          },
                          child: Text(
                            showUsedCards
                                ? '카드 정보로 돌아가기'
                                : '같이 사용된 카드 보기',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
  
  Widget _effectWidget(BuildContext context, String text, String category,
      Color categoryColor, double fontSize, String locale) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).splashColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category,
              style: TextStyle(color: categoryColor, fontSize: fontSize,
                  // fontFamily: locale=='JPN'?"MPLUSC":"JalnanGothic"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildEffectText(text, fontSize, locale),
          )
        ],
      ),
    );
  }

  Widget _attributeWidget(BuildContext context, List<String> attributes,
      String category, Color categoryColor, double fontSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                category,
                style: TextStyle(color: categoryColor, fontSize: fontSize),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: attributes
                        .map((attribute) => Chip(
                              label: Text(
                                attribute,
                                style: TextStyle(
                                    fontSize: fontSize *
                                        0.9), // Chip 내부 텍스트의 폰트 크기를 조정
                              ),
                            ))
                        .toList())),
          ],
        ),
      ),
    );
  }

  Widget buildEffectText(String text, double fontSize, String locale) {
    final String trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');
    final List<InlineSpan> spans = [];
    final RegExp regexp = RegExp(
        r'(【[^【】]*】|《[^《》]*》|\[[^\[\]]*\]|〈[^〈〉]*〉|\([^()]*\)|〔[^〔〕]*〕|디지크로스\s*-\d+)');

    final Iterable<Match> matches = regexp.allMatches(trimmedText);

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
        backgroundColor = const Color.fromRGBO(33, 37, 131, 1);
      } else if (matchedText.startsWith('《') && matchedText.endsWith('》')) {
        backgroundColor = const Color.fromRGBO(206, 101, 1, 1);
      } else if (matchedText.startsWith('[') && matchedText.endsWith(']')) {
        backgroundColor = const Color.fromRGBO(163, 23, 99, 1);
      } else if (matchedText.startsWith('〔') && matchedText.endsWith('〕')) {
        if (matchedText.contains('조그레스') || matchedText.contains('진화') || matchedText.contains('進化')) {
          backgroundColor = const Color.fromRGBO(33, 37, 131, 1);
        } else {
          backgroundColor = const Color.fromRGBO(163, 23, 99, 1);
        }
      } else if (matchedText.startsWith('〈') && matchedText.endsWith('〉')) {
        backgroundColor = const Color.fromRGBO(206, 101, 1, 1);
      } else if (matchedText.startsWith('(') && matchedText.endsWith(')')) {
        innerText = '($innerText)';
        backgroundColor = Colors.black54;
      } else if (RegExp(r'^디지크로스\s*-\d+$').hasMatch(matchedText)) {
        backgroundColor = const Color.fromRGBO(61, 178, 86, 1);
      } else {
        backgroundColor = Colors.black;
      }
      spans.add(TextSpan(
          text: matchedText, style: TextStyle(color: backgroundColor)));
      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black,
          height: 1.4,
            fontFamily: locale=='JPN'?"MPLUSC":"JalnanGothic"
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      semanticsLabel: trimmedText.replaceAll(RegExp(r'[【】《》\[\]〈〉()〔〕]'), ''),
    );
  }

  // Widget buildEffectText(String text, double fontSize, bool isEn) {
  //   // 줄바꿈 후 시작하는 공백 제거
  //   final String trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');
  //
  //   final List<InlineSpan> spans = [];
  //   final RegExp regexp = RegExp(
  //       r'(【[^【】]*】|《[^《》]*》|\[[^\[\]]*\]|〈[^〈〉]*〉|\([^()]*\)|〔[^〔〕]*〕)');
  //   final Iterable<Match> matches = regexp.allMatches(trimmedText);
  //
  //   spans
  //       .add(TextSpan(text: '', style: TextStyle(fontWeight: FontWeight.bold)));
  //
  //   int lastIndex = 0;
  //   for (final match in matches) {
  //     if (match.start > lastIndex) {
  //       spans
  //           .add(TextSpan(text: trimmedText.substring(lastIndex, match.start)));
  //     }
  //
  //     final String matchedText = match.group(0)!;
  //     String innerText = matchedText.substring(1, matchedText.length - 1);
  //     Color backgroundColor;
  //     if (matchedText.startsWith('【') && matchedText.endsWith('】')) {
  //       backgroundColor = Color.fromRGBO(33, 37, 131, 1);
  //     } else if (matchedText.startsWith('《') && matchedText.endsWith('》')) {
  //       backgroundColor = Color.fromRGBO(206, 101, 1, 1);
  //     } else if (matchedText.startsWith('[') && matchedText.endsWith(']')) {
  //       backgroundColor = Color.fromRGBO(163, 23, 99, 1);
  //     } else if (matchedText.startsWith('〔') && matchedText.endsWith('〕')) {
  //       backgroundColor = Color.fromRGBO(163, 23, 99, 1);
  //     } else if (matchedText.startsWith('〈') && matchedText.endsWith('〉')) {
  //       backgroundColor = Color.fromRGBO(206, 101, 1, 1);
  //     } else if (matchedText.startsWith('(') && matchedText.endsWith(')')) {
  //       innerText = '(' + innerText + ')';
  //       backgroundColor = Colors.transparent;
  //     } else {
  //       backgroundColor = Colors.transparent;
  //     }
  //
  //     spans.add(
  //       WidgetSpan(
  //         alignment: PlaceholderAlignment.middle,
  //         child: Container(
  //           padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
  //           margin: EdgeInsets.only(left: 2, right: 2),
  //           decoration: BoxDecoration(
  //             color: backgroundColor,
  //             borderRadius: BorderRadius.circular(4),
  //           ),
  //           child: Text(
  //             innerText,
  //             style: TextStyle(
  //               fontSize: fontSize,
  //               color: backgroundColor != Colors.transparent
  //                   ? Colors.white
  //                   : Colors.black,
  //               height: 1.4,
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     lastIndex = match.end;
  //   }
  //
  //   if (lastIndex < trimmedText.length) {
  //     spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
  //   }
  //
  //   return RichText(
  //     text: TextSpan(
  //       children: spans,
  //       style: TextStyle(
  //         fontSize: fontSize,
  //         color: Colors.black,
  //         height: 1.4,
  //         fontFamily: 'JalnanGothic',
  //       ),
  //     ),
  //   );
  // }

  Color getColor(double ratio) {
    if (ratio >= 0.8) {
      return Colors.green;
    }
    if (ratio >= 0.5) {
      return Colors.orange;
    }
    if (ratio > 0.2) {
      return Colors.yellow;
    }

    return Colors.black;
  }
}
