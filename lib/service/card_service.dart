import 'dart:math';

import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/use_card_response_dto.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:provider/provider.dart';
import '../model/card.dart';
import '../model/locale_card_data.dart';
import '../provider/text_simplify_provider.dart';
import 'color_service.dart';

class CardService {

  void showImageDialog(
      BuildContext context, DigimonCard card, Function(int)? searchNote) {
    CardOverlayService cardOverlayService = CardOverlayService();
    cardOverlayService.removeAllOverlays();
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
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
            LocaleCardData localeCardData =
            card.localeCardData[selectedLocaleIndex];

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
                            width:
                            isPortrait ? screenWidth * 0.8 : screenWidth * 0.3,
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
                                              color: ColorService
                                                  .getColorFromString(
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
                                              'Lv.${card.lv==0?'-':card.lv}',
                                              style: TextStyle(fontSize: fontSize),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: card.localeCardData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      LocaleCardData localeCardData = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedLocaleIndex = index;
                                            });
                                          },
                                          child: Text(
                                            localeCardData.locale,
                                            style: TextStyle(
                                              fontSize: fontSize * 0.8,
                                              color:
                                              selectedLocaleIndex == index
                                                  ? Theme.of(context)
                                                  .primaryColor
                                                  : Colors.grey,
                                              fontWeight:
                                              selectedLocaleIndex == index
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
                                        style: TextStyle(
                                          fontSize: fontSize * 1.2,
                                          fontFamily:
                                          localeCardData.locale == 'JPN'
                                              ? "MPLUSC"
                                              : "JalnanGothic",
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
                                                      width: constraints.maxWidth,
                                                      child: Image.network(
                                                        card.getDisplayImgUrl() ??
                                                            '',
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      bottom: 0,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context)
                                                              .canvasColor,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: IconButton(
                                                          padding: EdgeInsets.zero,
                                                          tooltip:
                                                          '이미지 다운로드',
                                                          onPressed: () async {
                                                            if (card
                                                                .getDisplayImgUrl() !=
                                                                null) {
                                                              await WebImageDownloader
                                                                  .downloadImageFromWeb(
                                                                card
                                                                    .getDisplayImgUrl()!,
                                                                name:
                                                                '${card.cardNo}_${card.getDisplayName()}.png',
                                                              );
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.download,
                                                            color: Theme.of(context)
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
                                                    ColorService.getColorFromString(
                                                        card.color1!),
                                                    fontSize),
                                              if (card.attribute != null)
                                                _attributeWidget(
                                                    context,
                                                    [card.attribute!],
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
                                        if (card.attribute != null)
                                          _attributeWidget(
                                              context,
                                              [card.attribute!],
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
                                  // 텍스트 간소화 스위치
                                  Consumer<TextSimplifyProvider>(
                                    builder: (context, textSimplifyProvider, child) {
                                      return Row(
                                        children: [
                                          Text('텍스트 간소화'),
                                          Switch(
                                            value:
                                            textSimplifyProvider.getTextSimplify(),
                                            onChanged: (v) {
                                              textSimplifyProvider
                                                  .updateTextSimplify(v);
                                            },
                                            inactiveThumbColor: Colors.red,
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 5),
                                  Consumer<TextSimplifyProvider>(
                                    builder: (context, textSimplifyProvider, child) {
                                      return Column(
                                        children: [
                                          if (localeCardData.effect != null)
                                            effectWidget(
                                              context,
                                              localeCardData.effect!,
                                              '상단 텍스트',
                                              ColorService.getColorFromString(card.color1!),
                                              fontSize,
                                              localeCardData.locale,
                                              textSimplifyProvider.getTextSimplify(),
                                            ),
                                          const SizedBox(height: 5),
                                          if (localeCardData.sourceEffect != null)
                                            effectWidget(
                                              context,
                                              localeCardData.sourceEffect!,
                                              '하단 텍스트',
                                              ColorService.getColorFromString(card.color1!),
                                              fontSize,
                                              localeCardData.locale,
                                              textSimplifyProvider.getTextSimplify(),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
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
                                      useCardResponseDto.usedCardList[index];
                                      final usedCard = usedCardInfo.card;
                                      return Container(
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(5)),
                                        child: ListTile(
                                          leading: Image.network(
                                              usedCard.getDisplaySmallImgUrl() ??
                                                  ''),
                                          title: Text(
                                            usedCard.getDisplayName() ?? '',
                                            style: TextStyle(
                                                color:
                                                getColor(usedCardInfo.ratio)),
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
          },
        );
      },
    );
  }


  Widget effectWidget(BuildContext context, String text, String category,
      Color categoryColor, double fontSize, String locale, bool isTextSimplify) {
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
              style: TextStyle(
                color: categoryColor, fontSize: fontSize,
                // fontFamily: locale=='JPN'?"MPLUSC":"JalnanGothic"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildEffectText(text, fontSize, locale, isTextSimplify),
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

  List<InlineSpan> _getKorTextSpans(String text) {
    final spans = <InlineSpan>[];
    final trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');

    final matchStyles = [
      {
        'pattern': r'《[^《》]*《[^《》]*》[^《》]*》',
        'color': const Color.fromRGBO(206, 101, 1, 1),
      },
      // {
      //   'pattern': r'《오버플로우 《-?\d+》》',
      //   'color': const Color.fromRGBO(206, 101, 1, 1),
      // },
      // {
      //   'pattern': r'《디코드《[^《》]+》》',
      //   'color': const Color.fromRGBO(206, 101, 1, 1),
      // },
      {
        'pattern': r'《[^《》]*》',
        'color': const Color.fromRGBO(206, 101, 1, 1),
      },
      {
        'pattern': r'≪[^≪≫]*≫',
        'color': const Color.fromRGBO(206, 101, 1, 1),
      },
      {
        'pattern': r'【[^【】]*】',
        'color': const Color.fromRGBO(33, 37, 131, 1),
      },
      {
        'pattern': r'\[[^\[\]]*\]',
        'color': const Color.fromRGBO(163, 23, 99, 1),
      },
      {
        'pattern': r'〔[^〔〕]*〕',
        'colorEvaluator': (String matchedText) =>
            matchedText.contains('조그레스') || matchedText.contains('진화')
                ? const Color.fromRGBO(59, 88, 101, 1.0)
                : const Color.fromRGBO(163, 23, 99, 1),
      },
      {
        'pattern': r'〈[^〈〉]*〉',
        'color': const Color.fromRGBO(206, 101, 1, 1),
      },
      // 수정된 패턴: () 안에 《...》가 포함되지 않도록 함
      // {
      //   'pattern': r'\((?:(?!《[^《》]*》)[^()])*?\)',
      //   'color': Colors.black54,
      // },
      {
        'pattern': r'디지크로스\s*-\d+',
        'color': const Color.fromRGBO(61, 178, 86, 1),
      },
    ];

    // 패턴들을 우선순위에 맞게 정렬 (《...》이 먼저 오도록)
    final pattern = matchStyles.map((e) => e['pattern'] as String).join('|');
    final regexp = RegExp(pattern);
    final matches = regexp.allMatches(trimmedText);

    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: trimmedText.substring(lastIndex, match.start),
          style: const TextStyle(color: Colors.black), // 기본 색상 설정
        ));
      }

      final matchedText = match.group(0)!;

      final styleConfig = matchStyles.firstWhere(
        (config) => RegExp(config['pattern'] as String).hasMatch(matchedText),
      );

      final backgroundColor = styleConfig['colorEvaluator'] != null
          ? (styleConfig['colorEvaluator'] as Function)(matchedText)
          : styleConfig['color'] as Color;

      spans.add(TextSpan(
        text: matchedText,
        style: TextStyle(color: backgroundColor),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(
        text: trimmedText.substring(lastIndex),
        style: const TextStyle(color: Colors.black), // 기본 색상 설정
      ));
    }

    return spans;
  }

  List<InlineSpan> _getEngTextSpans(String text) {
    final spans = <InlineSpan>[];
    final trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');

    final matchStyles = [
      {
        'pattern': r'\[[^\[\]]*\]',
        'colorEvaluator': (String matchedText) {
          if ([
            'Your Turn',
            'When Attacking',
            'When Digivolving',
            'Security',
            'Start of Your Main Phase',
            'All Turns',
            'On Play',
            'Opponent\'s Turn',
            'Counter',
            'On Deletion',
            'Digivolve',
            'Main'
          ].any((keyword) => matchedText.contains(keyword))) {
            return const Color.fromRGBO(33, 37, 131, 1);
          } else if ([
            'Hand',
            'Per Turn',
          ].any((keyword) => matchedText.contains(keyword))) {
            return const Color.fromRGBO(163, 23, 99, 1);
          } else {
            return Colors.black;
          }
        },
      },
      {
        'pattern': r'〔[^〔〕]*〕',
        'color': const Color.fromRGBO(33, 37, 131, 1),
      },
      {
        'pattern': r'＜[^＜＞]*＞',
        'color': const Color.fromRGBO(206, 101, 1, 1),
      },
      {
        'pattern': r'\([^()]*\)',
        'color': Colors.black54,
      },
      {
        'pattern': r'DigiXros \s*-\d+',
        'color': const Color.fromRGBO(61, 178, 86, 1),
      },
    ];

    final pattern = matchStyles.map((e) => e['pattern'] as String).join('|');
    final regexp = RegExp(pattern);
    final matches = regexp.allMatches(trimmedText);

    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans
            .add(TextSpan(text: trimmedText.substring(lastIndex, match.start)));
      }

      final matchedText = match.group(0)!;

      final styleConfig = matchStyles.firstWhere(
        (config) => RegExp(config['pattern'] as String).hasMatch(matchedText),
      );

      final backgroundColor = styleConfig['colorEvaluator'] != null
          ? (styleConfig['colorEvaluator'] as Function)(matchedText)
          : styleConfig['color'] as Color;

      spans.add(TextSpan(
          text: matchedText, style: TextStyle(color: backgroundColor)));
      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
    }

    return spans;
  }

  List<InlineSpan> _getJpnTextSpans(String text) {
    final spans = <InlineSpan>[];
    final trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');

    final matchStyles = [
      {
        'pattern': r'〔[^〔〕]*〕',
        'color': const Color.fromRGBO(33, 37, 131, 1),
      },
      {
        'pattern': r'【[^【】]*】',
        'color': const Color.fromRGBO(33, 37, 131, 1),
      },
      {
        'pattern': r'\[[^\[\]]*\]',
        'color': const Color.fromRGBO(163, 23, 99, 1),
      },
      {
        'pattern': r'［[^［］]*］',
        'color': const Color.fromRGBO(163, 23, 99, 1),
      },
      {
        'pattern': r'≪[^≪≫]*≫',
        'color': const Color.fromRGBO(206, 101, 1, 1),
      },
      {
        'pattern': r'（[^（）]*）',
        'color': Colors.black54,
      },
      {
        'pattern': r'デジクロス\s*-\d+',
        'color': const Color.fromRGBO(61, 178, 86, 1),
      },
    ];

    final pattern = matchStyles.map((e) => e['pattern'] as String).join('|');
    final regexp = RegExp(pattern);
    final matches = regexp.allMatches(trimmedText);

    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans
            .add(TextSpan(text: trimmedText.substring(lastIndex, match.start)));
      }

      final matchedText = match.group(0)!;

      final styleConfig = matchStyles.firstWhere(
        (config) => RegExp(config['pattern'] as String).hasMatch(matchedText),
      );

      final backgroundColor = styleConfig['colorEvaluator'] != null
          ? (styleConfig['colorEvaluator'] as Function)(matchedText)
          : styleConfig['color'] as Color;

      spans.add(TextSpan(
          text: matchedText, style: TextStyle(color: backgroundColor)));
      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
    }

    return spans;
  }

  Widget buildEffectText(String text, double fontSize, String locale, bool isTextSimplify) {
    final List<InlineSpan> spans = [];

    spans.addAll(getSpansByLocale(locale, text, isTextSimplify));

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            height: 1.4,
            fontFamily: locale == 'JPN' ? "MPLUSC" : "JalnanGothic"),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
  }

  List<InlineSpan> getSpansByLocale(
      String locale, String text, bool isTextSimplify) {
    if (isTextSimplify) {
      final RegExp pattern1 = RegExp(r'（[^（）]*）');
      final RegExp pattern2 = RegExp(r'\([^()]*\)');
      text = text.replaceAll(pattern1, "");
      text = text.replaceAll(pattern2, "");
    }
    if (locale == "KOR") {
      return _getKorTextSpans(text);
    } else if (locale == "ENG") {
      return _getEngTextSpans(text);
    } else if (locale == "JPN") {
      return _getJpnTextSpans(text);
    }
    return [];
  }

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
