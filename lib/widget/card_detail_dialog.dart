import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/locale_card_data.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/use_card_response_dto.dart';
import 'package:digimon_meta_site_flutter/provider/locale_provider.dart';
import 'package:digimon_meta_site_flutter/provider/text_simplify_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/color_service.dart';
import 'package:digimon_meta_site_flutter/service/keyword_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:provider/provider.dart';

class CardDetailDialog extends StatefulWidget {
  final DigimonCard card;
  final Function(SearchParameter)? searchWithParameter;
  final KeywordService keywordService;
  final bool keywordsLoaded;

  const CardDetailDialog({
    Key? key,
    required this.card,
    this.searchWithParameter,
    required this.keywordService,
    required this.keywordsLoaded,
  }) : super(key: key);

  @override
  State<CardDetailDialog> createState() => _CardDetailDialogState();
}

class _CardDetailDialogState extends State<CardDetailDialog> {
  bool _showUsedCards = false;
  bool _showOtherIllustrations = false;
  UseCardResponseDto _useCardResponseDto = UseCardResponseDto(
    usedCardList: [],
    totalCount: 0,
    initialize: false,
  );
  List<DigimonCard> _otherIllustrations = [];
  int _selectedLocaleIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSelectedLocale();
  }

  void _initializeSelectedLocale() {
    // LocaleProvider에서 우선순위를 가져와 초기 탭 설정
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final localePriority = localeProvider.localePriority;

    // 카드가 가진 locale 중에서 우선순위가 가장 높은 것을 찾기
    for (String priorityLocale in localePriority) {
      for (int i = 0; i < widget.card.localeCardData.length; i++) {
        if (widget.card.localeCardData[i].locale == priorityLocale) {
          _selectedLocaleIndex = i;
          return; // 찾으면 바로 종료
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final fontSize = min(screenWidth * 0.03, 15.0);

    LocaleCardData localeCardData =
        widget.card.localeCardData[_selectedLocaleIndex];

    return AlertDialog(
      content: Stack(
        children: [
          Column(
            children: [
              if (_showUsedCards) ...[
                Text(
                  '같이 사용된 카드',
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '총 ${_useCardResponseDto.totalCount}개의 덱에서 이 카드가 사용되었습니다.',
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: 10),
              ] else if (_showOtherIllustrations) ...[
                Text(
                  '이 카드의 다른 일러스트',
                  style: TextStyle(
                    fontSize: fontSize * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '카드 번호: ${widget.card.cardNo}',
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: 10),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: isPortrait ? screenWidth * 0.8 : screenWidth * 0.3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_showUsedCards && !_showOtherIllustrations) ...[
                          _buildCardHeader(context, fontSize),
                          _buildLocaleSelector(context, fontSize),
                          SizedBox(height: 10),
                          _buildCardName(localeCardData, fontSize),
                          SizedBox(height: 10),
                          _buildCardImageAndAttributes(
                              context, isPortrait, fontSize, localeCardData),
                          if (isPortrait)
                            _buildAttributesRow(context, fontSize),
                          const SizedBox(height: 5),
                          _buildCardEffects(context, localeCardData, fontSize),
                          const SizedBox(height: 10),
                          _buildCardSource(context, fontSize),
                        ] else if (_showUsedCards) ...[
                          _buildUsedCardsList(context, fontSize),
                        ] else if (_showOtherIllustrations) ...[
                          _buildOtherIllustrationsList(context, fontSize),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleUsedCards,
                      child: Text(
                        _showUsedCards ? '카드 정보로 돌아가기' : '같이 사용된 카드 보기',
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Close dialog and search for cards with the same cardNo
                        Navigator.pop(context);
                        if (widget.card.cardNo != null &&
                            widget.searchWithParameter != null) {
                          SearchParameter parameter = SearchParameter();
                          parameter.searchString = widget.card.cardNo!;
                          widget.searchWithParameter!(parameter);
                        }
                      },
                      child: Text(
                        '다른 일러스트 검색',
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUsedCards() async {
    if (_showOtherIllustrations) {
      setState(() {
        _showOtherIllustrations = false;
        _showUsedCards = true;
      });
    } else {
      setState(() {
        _showUsedCards = !_showUsedCards;
        if (_showOtherIllustrations) _showOtherIllustrations = false;
      });
    }

    if (_showUsedCards && !_useCardResponseDto.initialize) {
      final response = await CardApi().getUseCard(widget.card.cardId!);
      setState(() {
        _useCardResponseDto = response;
      });
    }
  }

  Future<void> _toggleOtherIllustrations() async {
    if (_showUsedCards) {
      setState(() {
        _showUsedCards = false;
        _showOtherIllustrations = true;
      });
    } else {
      setState(() {
        _showOtherIllustrations = !_showOtherIllustrations;
        if (_showUsedCards) _showUsedCards = false;
      });
    }

    if (_showOtherIllustrations && _otherIllustrations.isEmpty) {
      // Search cards with the same cardNo
      final cardList = await CardApi().searchCards(cardNo: widget.card.cardNo);
      setState(() {
        // Filter out the current card if needed
        _otherIllustrations = cardList
            .where((card) => card.cardId != widget.card.cardId)
            .toList();

        // If no other illustrations found, include the current one
        if (_otherIllustrations.isEmpty) {
          _otherIllustrations = [widget.card];
        }
      });
    }
  }

  Widget _buildCardHeader(BuildContext context, double fontSize) {
    return Container(
      width: double.infinity,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        children: [
          Text(
            '${widget.card.cardNo}',
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).hintColor,
            ),
          ),
          Text(
            '${widget.card.rarity}',
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            '${widget.card.getKorCardType()}',
            style: TextStyle(
              fontSize: fontSize,
              color: ColorService.getColorFromString(widget.card.color1!),
            ),
          ),
          if (widget.card.lv != null)
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Theme.of(context).cardColor,
                disabledForegroundColor: Colors.black,
              ),
              child: Text(
                'Lv.${widget.card.lv == 0 ? '-' : widget.card.lv}',
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.normal),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocaleSelector(BuildContext context, double fontSize) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        // 우선순위에 따라 로케일 데이터 정렬
        List<MapEntry<int, LocaleCardData>> sortedEntries =
            widget.card.localeCardData.asMap().entries.toList();

        // 우선순위에 따라 정렬
        sortedEntries.sort((a, b) {
          int priorityA = localeProvider.localePriority.indexOf(a.value.locale);
          int priorityB = localeProvider.localePriority.indexOf(b.value.locale);

          // 우선순위 리스트에 없으면 맨 뒤로
          if (priorityA == -1) priorityA = 999;
          if (priorityB == -1) priorityB = 999;

          return priorityA.compareTo(priorityB);
        });

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: sortedEntries.map((entry) {
            int index = entry.key;
            LocaleCardData localeCardData = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedLocaleIndex = index;
                  });
                },
                child: Text(
                  localeCardData.locale,
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: _selectedLocaleIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    fontWeight: _selectedLocaleIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCardName(LocaleCardData localeCardData, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          localeCardData.name ?? '데이터 없음',
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontFamily:
                localeCardData.locale == 'JPN' ? "MPLUSC" : "JalnanGothic",
          ),
        ),
      ],
    );
  }

  Widget _buildCardImageAndAttributes(BuildContext context, bool isPortrait,
      double fontSize, LocaleCardData localeCardData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Consumer<LocaleProvider>(
                          builder: (context, localeProvider, child) {
                            return Image.network(
                              (localeCardData.imgUrl ??
                                      widget.card.getDisplayImgUrl(
                                          localeProvider.localePriority)) ??
                                  '',
                              fit: BoxFit.fitWidth,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: '이미지 다운로드',
                            onPressed: () async {
                              final localeProvider =
                                  Provider.of<LocaleProvider>(context,
                                      listen: false);
                              final imgUrl = widget.card.getDisplayImgUrl(
                                  localeProvider.localePriority);
                              if (imgUrl != null) {
                                await WebImageDownloader.downloadImageFromWeb(
                                  imgUrl,
                                  name:
                                      '${widget.card.cardNo}_${widget.card.getDisplayName(localeProvider.localePriority)}.png',
                                );
                              }
                            },
                            icon: Icon(
                              Icons.download,
                              color: Theme.of(context).primaryColor,
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
                if (widget.card.form != null)
                  _attributeWidget(
                    context,
                    [widget.card.getKorForm()],
                    '형태',
                    ColorService.getColorFromString(widget.card.color1!),
                    fontSize,
                  ),
                if (widget.card.attribute != null)
                  _attributeWidget(
                    context,
                    [widget.card.attribute!],
                    '속성',
                    ColorService.getColorFromString(widget.card.color1!),
                    fontSize,
                  ),
                if (widget.card.types != null && widget.card.types!.isNotEmpty)
                  _attributeWidget(
                    context,
                    widget.card.types!,
                    '유형',
                    ColorService.getColorFromString(widget.card.color1!),
                    fontSize,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAttributesRow(BuildContext context, double fontSize) {
    return Column(
      children: [
        SizedBox(height: 5),
        AutoScrollingWidget(
          duration: Duration(
              milliseconds:
                  ((widget.card.form?.contains('/') ?? false) ? 2 : 1) +
                      1 +
                      ((widget.card.types?.length ?? 0)) * 2000),
          pauseDuration: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.card.form != null)
                _attributeCompactWidget(
                  context,
                  [widget.card.getKorForm()],
                  '형태',
                  ColorService.getColorFromString(widget.card.color1!),
                  fontSize,
                ),
              SizedBox(width: 8),
              if (widget.card.attribute != null)
                _attributeCompactWidget(
                  context,
                  [widget.card.attribute!],
                  '속성',
                  ColorService.getColorFromString(widget.card.color1!),
                  fontSize,
                ),
              SizedBox(width: 8),
              if (widget.card.types != null && widget.card.types!.isNotEmpty)
                _attributeCompactWidget(
                  context,
                  widget.card.types!,
                  '유형',
                  ColorService.getColorFromString(widget.card.color1!),
                  fontSize,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attributeCompactWidget(
    BuildContext context,
    List<String> attributes,
    String category,
    Color categoryColor,
    double fontSize,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$category: ',
            style: TextStyle(
              color: categoryColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: attributes.expand((attribute) {
              // "/" 문자가 포함된 경우, 분리하여 각각의 칩으로 만듦
              if (attribute.contains('/')) {
                final parts = attribute.split('/');
                return parts.map((part) => Chip(
                      label: Text(
                        part.trim(),
                        style: TextStyle(fontSize: fontSize * 0.9),
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                    ));
              } else {
                // 기존과 같이 단일 칩으로 표시
                return [
                  Chip(
                    label: Text(
                      attribute,
                      style: TextStyle(fontSize: fontSize * 0.9),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                  )
                ];
              }
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _attributeWidget(
    BuildContext context,
    List<String> attributes,
    String category,
    Color categoryColor,
    double fontSize,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(8.0),
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
              children: attributes.expand((attribute) {
                // "/" 문자가 포함된 경우, 분리하여 각각의 칩으로 만듦
                if (attribute.contains('/')) {
                  final parts = attribute.split('/');
                  return parts.map((part) => Tooltip(
                        message: part.trim(),
                        triggerMode: TooltipTriggerMode.tap,
                        child: Chip(
                          label: Text(
                            part.trim(),
                            style: TextStyle(fontSize: fontSize * 0.9),
                          ),
                        ),
                      ));
                } else {
                  // 기존과 같이 단일 칩으로 표시
                  return [
                    Tooltip(
                      message: attribute,
                      triggerMode: TooltipTriggerMode.tap,
                      child: Chip(
                        label: Text(
                          attribute,
                          style: TextStyle(fontSize: fontSize * 0.9),
                        ),
                      ),
                    )
                  ];
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEffects(
      BuildContext context, LocaleCardData localeCardData, double fontSize) {
    return Consumer<TextSimplifyProvider>(
      builder: (context, textSimplifyProvider, child) {
        return Column(
          children: [
            if (localeCardData.effect != null &&
                localeCardData.effect!.isNotEmpty)
              _effectWidget(
                context,
                localeCardData.effect!,
                '상단 텍스트',
                ColorService.getColorFromString(widget.card.color1!),
                fontSize,
                localeCardData.locale,
                true,
              ),
            const SizedBox(height: 5),
            if (localeCardData.sourceEffect != null &&
                localeCardData.sourceEffect!.isNotEmpty)
              _effectWidget(
                context,
                localeCardData.sourceEffect!,
                '하단 텍스트',
                ColorService.getColorFromString(widget.card.color1!),
                fontSize,
                localeCardData.locale,
                true,
              ),
          ],
        );
      },
    );
  }

  Widget _buildCardSource(BuildContext context, double fontSize) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () {
          if (widget.searchWithParameter != null &&
              widget.card.noteId != null) {
            Navigator.pop(context);
            SearchParameter parameter = SearchParameter();
            parameter.noteIds = {widget.card.noteId!};
            widget.searchWithParameter!(parameter);
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
                widget.card.noteName ?? '',
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
    );
  }

  Widget _buildUsedCardsList(BuildContext context, double fontSize) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _useCardResponseDto.usedCardList.length,
      itemBuilder: (BuildContext context, int index) {
        final usedCardInfo = _useCardResponseDto.usedCardList[index];
        final usedCard = usedCardInfo.card;
        return Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            leading: Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return Image.network(usedCard
                        .getDisplaySmallImgUrl(localeProvider.localePriority) ??
                    '');
              },
            ),
            title: Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return Text(
                  usedCard.getDisplayName(localeProvider.localePriority) ?? '',
                  style: TextStyle(color: _getColor(usedCardInfo.ratio)),
                );
              },
            ),
            subtitle: Text(
              '덱: ${usedCardInfo.count}, 비율: ${(usedCardInfo.ratio * 100).toStringAsFixed(0)}%',
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to the selected card detail
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CardDetailDialog(
                    card: usedCard,
                    searchWithParameter: widget.searchWithParameter,
                    keywordService: widget.keywordService,
                    keywordsLoaded: widget.keywordsLoaded,
                  );
                },
              );
            },
            trailing: Text(
              '${usedCardInfo.rank}위',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtherIllustrationsList(BuildContext context, double fontSize) {
    if (_otherIllustrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('일러스트를 검색 중입니다...'),
          ],
        ),
      );
    }

    if (_otherIllustrations.length == 1 &&
        _otherIllustrations.first.cardId == widget.card.cardId) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '이 카드의 다른 일러스트를 찾지 못했습니다.',
            style: TextStyle(fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _otherIllustrations.length,
      itemBuilder: (BuildContext context, int index) {
        final card = _otherIllustrations[index];
        // Highlight current card
        final bool isCurrentCard = card.cardId == widget.card.cardId;

        return Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isCurrentCard ? Colors.grey.withOpacity(0.2) : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: isCurrentCard
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
          ),
          child: ListTile(
            leading: Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return Image.network(
                    card.getDisplaySmallImgUrl(localeProvider.localePriority) ??
                        '');
              },
            ),
            title: Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
              return Text(
                card.getDisplayName(localeProvider.localePriority) ?? '',
                style: TextStyle(
                  fontWeight:
                      isCurrentCard ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }),
            subtitle: Text(
              '세트: ${card.noteName ?? '정보 없음'}',
            ),
            isThreeLine: false,
            onTap: () {
              if (!isCurrentCard) {
                Navigator.pop(context);
                // Navigate to selected card
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CardDetailDialog(
                      card: card,
                      searchWithParameter: widget.searchWithParameter,
                      keywordService: widget.keywordService,
                      keywordsLoaded: widget.keywordsLoaded,
                    );
                  },
                );
              }
            },
            trailing: isCurrentCard
                ? Icon(Icons.check_circle,
                    color: Theme.of(context).primaryColor)
                : null,
          ),
        );
      },
    );
  }

  Widget _effectWidget(
    BuildContext context,
    String text,
    String category,
    Color categoryColor,
    double fontSize,
    String locale,
    bool isTextSimplify,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category,
              style: TextStyle(
                color: categoryColor,
                fontSize: fontSize,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildEffectText(
                context, text, fontSize, locale, isTextSimplify),
          )
        ],
      ),
    );
  }

  Widget _buildEffectText(
    BuildContext context,
    String text,
    double fontSize,
    String locale,
    bool isTextSimplify,
  ) {
    // 현재 활성화된 효과 설명을 추적하기 위한 상태
    final ValueNotifier<String?> activeDescriptionKey =
        ValueNotifier<String?>(null);

    final List<InlineSpan> spans = [];

    spans.addAll(_getSpansByLocale(locale, text, isTextSimplify,
        onBracketTap: (String bracketText) {
      // 괄호에서 텍스트 추출
      String content = bracketText;
      if (content.startsWith('《') && content.endsWith('》')) {
        content = content.substring(1, content.length - 1);
      } else if (content.startsWith('≪') && content.endsWith('≫')) {
        content = content.substring(1, content.length - 1);
      } else if (content.startsWith('＜') && content.endsWith('＞')) {
        content = content.substring(1, content.length - 1);
      }

      // 같은 항목 클릭 시 토글
      if (activeDescriptionKey.value == content) {
        activeDescriptionKey.value = null;
      } else {
        activeDescriptionKey.value = content;
      }
    }));

    return ValueListenableBuilder<String?>(
        valueListenable: activeDescriptionKey,
        builder: (context, activeKey, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 메인 텍스트
              SelectableText.rich(
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
              ),

              // 활성화된 설명이 있으면 표시
              if (activeKey != null)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        )
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 (키워드 이름)
                      Row(
                        children: [
                          // 키워드 이름 (주황색으로 변경, 아이콘 제거)
                          Text(
                            activeKey,
                            style: TextStyle(
                              fontSize: fontSize * 0.9,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(
                                  206, 101, 1, 1), // 주황색으로 변경
                            ),
                          ),

                          const Spacer(),

                          // 닫기 버튼
                          InkWell(
                            onTap: () {
                              activeDescriptionKey.value = null;
                            },
                            child: Icon(
                              Icons.close,
                              size: fontSize * 0.8,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      // 구분선
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.3),
                          height: 1,
                        ),
                      ),

                      // 효과 설명 텍스트
                      Text(
                        _getEffectDescriptionText(activeKey),
                        style: TextStyle(
                          fontSize: fontSize * 0.85,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        });
  }

  // 효과 설명 텍스트를 반환하는 헬퍼 메서드
  String _getEffectDescriptionText(String content) {
    // 키워드 서비스에서 설명 가져오기
    if (widget.keywordsLoaded) {
      return widget.keywordService.getKeywordDescription(content);
    }

    // 설명이 없을 경우 기본 반환
    return '이 효과에 대한 자세한 설명이 없습니다.';
  }

  List<InlineSpan> _getSpansByLocale(
      String locale, String text, bool isTextSimplify,
      {Function(String)? onBracketTap}) {
    if (isTextSimplify) {
      // 수정된 코드: '》' 뒤에 오는 괄호만 제거
      // 한국어: '》' 뒤에 오는 괄호
      final RegExp korPattern1 = RegExp(r'》\s*\([^()]*\)');
      final RegExp korPattern2 = RegExp(r'》\s*（[^（）]*）');

      // 일본어: '》' 뒤에 오는 괄호
      final RegExp jpnPattern = RegExp(r'》\s*（[^（）]*）');

      // 영어: '>' 뒤에 오는 괄호
      final RegExp engPattern = RegExp(r'>\s*\([^()]*\)');

      // 괄호 제거 함수: 매치된 텍스트에서 괄호 부분만 제거하고 '》'는 유지
      String removeParentheses(String match) {
        // '》' 또는 '>' 이후의 내용은 제거
        if (match.contains('》')) {
          return '》';
        } else if (match.contains('>')) {
          return '>';
        }
        return '';
      }

      // 괄호 제거 적용
      text = text.replaceAllMapped(
          korPattern1, (match) => removeParentheses(match.group(0)!));
      text = text.replaceAllMapped(
          korPattern2, (match) => removeParentheses(match.group(0)!));
      text = text.replaceAllMapped(
          jpnPattern, (match) => removeParentheses(match.group(0)!));
      text = text.replaceAllMapped(
          engPattern, (match) => removeParentheses(match.group(0)!));
    }

    if (locale == "KOR") {
      return _getKorTextSpans(text, onBracketTap);
    } else if (locale == "ENG") {
      return _getEngTextSpans(text, onBracketTap: onBracketTap);
    } else if (locale == "JPN") {
      return _getJpnTextSpans(text, onBracketTap: onBracketTap);
    }
    return [];
  }

  List<InlineSpan> _getKorTextSpans(
      String text, Function(String)? onBracketTap) {
    final spans = <InlineSpan>[];
    final trimmedText = text.replaceAll(RegExp(r'\n\s+'), '\n');

    final matchStyles = [
      {
        'pattern': r'《[^《》]*《[^《》]*》[^《》]*》',
        'color': const Color.fromRGBO(206, 101, 1, 1),
        'clickable': true,
      },
      {
        'pattern': r'《[^《》]*》',
        'color': const Color.fromRGBO(206, 101, 1, 1),
        'clickable': true,
      },
      {
        'pattern': r'≪[^≪≫]*≫',
        'color': const Color.fromRGBO(206, 101, 1, 1),
        'clickable': true,
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
            matchedText.contains('조그레스') ||
                    matchedText.contains('진화') ||
                    matchedText.contains('어플합체')
                ? const Color.fromRGBO(59, 88, 101, 1.0)
                : const Color.fromRGBO(163, 23, 99, 1),
      },
      {
        'pattern': r'〈[^〈〉]*〉',
        'color': const Color.fromRGBO(206, 101, 1, 1),
        'clickable': false,
      },
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

      // Check if this style is clickable
      final isClickable =
          styleConfig['clickable'] == true && onBracketTap != null;

      if (isClickable) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
            color: backgroundColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onBracketTap!(matchedText);
            },
        ));
      } else {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: backgroundColor),
        ));
      }

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

  List<InlineSpan> _getEngTextSpans(String text,
      {Function(String)? onBracketTap}) {
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
        'clickable': true,
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

      // Check if this style is clickable
      final isClickable =
          styleConfig['clickable'] == true && onBracketTap != null;

      if (isClickable) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
            color: backgroundColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onBracketTap!(matchedText);
            },
        ));
      } else {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: backgroundColor),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
    }

    return spans;
  }

  List<InlineSpan> _getJpnTextSpans(String text,
      {Function(String)? onBracketTap}) {
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
        'clickable': true,
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

      // Check if this style is clickable
      final isClickable =
          styleConfig['clickable'] == true && onBracketTap != null;

      if (isClickable) {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
            color: backgroundColor,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onBracketTap!(matchedText);
            },
        ));
      } else {
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: backgroundColor),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < trimmedText.length) {
      spans.add(TextSpan(text: trimmedText.substring(lastIndex)));
    }

    return spans;
  }

  Color _getColor(double ratio) {
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

class AutoScrollingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double pauseDuration;
  final Curve curve;

  const AutoScrollingWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 10),
    this.pauseDuration = 2.0,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  State<AutoScrollingWidget> createState() => _AutoScrollingWidgetState();
}

class _AutoScrollingWidgetState extends State<AutoScrollingWidget>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _contentWidth = 0;
  double _viewportWidth = 0;
  bool _hasOverflow = false;
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );

    _animation.addListener(_updateScroll);

    // Start animation after layout is complete and we know content size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForOverflow();
      if (_hasOverflow) {
        _startScrolling();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _pauseTimer?.cancel();
    super.dispose();
  }

  void _checkForOverflow() {
    if (!_scrollController.hasClients) return;

    _contentWidth = _scrollController.position.maxScrollExtent +
        _scrollController.position.viewportDimension;
    _viewportWidth = _scrollController.position.viewportDimension;

    _hasOverflow = _contentWidth > _viewportWidth;

    if (_hasOverflow && !_animationController.isAnimating) {
      _startScrolling();
    }
  }

  void _updateScroll() {
    if (!_scrollController.hasClients) return;

    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) return;

    double scrollPosition = maxScrollExtent * _animation.value;
    _scrollController.jumpTo(scrollPosition);
  }

  void _startScrolling() {
    _animationController.forward().then((_) {
      // Pause at the end
      _pauseTimer = Timer(Duration(seconds: widget.pauseDuration.toInt()), () {
        if (mounted) {
          // Reset to beginning
          _scrollController.jumpTo(0);
          _animationController.reset();
          // Start again
          _startScrolling();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkForOverflow();
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(), // Disable manual scrolling
          child: widget.child,
        ),
      ),
    );
  }
}
