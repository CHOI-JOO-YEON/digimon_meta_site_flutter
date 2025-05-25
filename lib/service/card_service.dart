import 'dart:math';

import 'package:digimon_meta_site_flutter/api/card_api.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/use_card_response_dto.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/keyword_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/card_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:provider/provider.dart';
import '../model/card.dart';
import '../model/locale_card_data.dart';
import '../provider/text_simplify_provider.dart';
import 'color_service.dart';

class CardService {
  final KeywordService _keywordService = KeywordService();
  bool _keywordsLoaded = false;

  CardService() {
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    await _keywordService.loadKeywords();
    _keywordsLoaded = true;
  }

  void showImageDialog(
      BuildContext context, DigimonCard card, {Function(SearchParameter)? searchWithParameter}) {
    CardOverlayService cardOverlayService = CardOverlayService();
    cardOverlayService.removeAllOverlays();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CardDetailDialog(
          card: card,
          searchWithParameter: searchWithParameter,
          keywordService: _keywordService,
          keywordsLoaded: _keywordsLoaded,
        );
      },
    );
  }

  Widget effectWidget(
      BuildContext context,
      String text,
      String category,
      Color categoryColor,
      double fontSize,
      String locale,
      bool isTextSimplify) {
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
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildEffectText(context, text, fontSize, locale, isTextSimplify),
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
                    children: attributes.expand((attribute) {
                      // "/" 문자가 포함된 경우, 분리하여 각각의 칩으로 만듦
                      if (attribute.contains('/')) {
                        final parts = attribute.split('/');
                        return parts.map((part) => Chip(
                              label: Text(
                                part.trim(),
                                style: TextStyle(
                                    fontSize: fontSize * 0.9),
                              ),
                            ));
                      } else {
                        // 기존과 같이 단일 칩으로 표시
                        return [
                          Chip(
                            label: Text(
                              attribute,
                              style: TextStyle(fontSize: fontSize * 0.9),
                            ),
                          )
                        ];
                      }
                    }).toList())),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> getSpansByLocale(
      String locale, String text, bool isTextSimplify, {Function(String)? onBracketTap}) {
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
      text = text.replaceAllMapped(korPattern1, (match) => removeParentheses(match.group(0)!));
      text = text.replaceAllMapped(korPattern2, (match) => removeParentheses(match.group(0)!));
      text = text.replaceAllMapped(jpnPattern, (match) => removeParentheses(match.group(0)!));
      text = text.replaceAllMapped(engPattern, (match) => removeParentheses(match.group(0)!));
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

  List<InlineSpan> _getKorTextSpans(String text, Function(String)? onBracketTap) {
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
            matchedText.contains('조그레스') || matchedText.contains('진화') || matchedText.contains('어플합체')
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
      final isClickable = styleConfig['clickable'] == true && onBracketTap != null;

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

  List<InlineSpan> _getEngTextSpans(String text, {Function(String)? onBracketTap}) {
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
      final isClickable = styleConfig['clickable'] == true && onBracketTap != null;

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

  List<InlineSpan> _getJpnTextSpans(String text, {Function(String)? onBracketTap}) {
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
      final isClickable = styleConfig['clickable'] == true && onBracketTap != null;

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

  Widget buildEffectText(
      BuildContext context,
      String text, 
      double fontSize, 
      String locale, 
      bool isTextSimplify) {
    // 현재 활성화된 효과 설명을 추적하기 위한 상태
    final ValueNotifier<String?> activeDescriptionKey = ValueNotifier<String?>(null);
    
    final List<InlineSpan> spans = [];

    spans.addAll(getSpansByLocale(locale, text, isTextSimplify, 
      onBracketTap: (String bracketText) {
        // 괄호에서 텍스트 추출
        String content = bracketText;
        if (content.startsWith('《') && content.endsWith('》')) {
          content = content.substring(1, content.length - 1);
          
          // 중첩된 괄호가 있는지 확인 (예: 리커버리 +1 《덱》)
          // 여기서는 전체 내용을 그대로 유지하고 KeywordService가 패턴을 인식하도록 함
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
      }
    ));

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
                  border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                ),
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
                            color: const Color.fromRGBO(206, 101, 1, 1), // 주황색으로 변경
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
      }
    );
  }
  
  // 효과 설명 텍스트를 반환하는 헬퍼 메서드
  String _getEffectDescriptionText(String content) {
    // 키워드 서비스에서 설명 가져오기
    if (_keywordsLoaded) {
      return _keywordService.getKeywordDescription(content);
    }
    
    // 설명이 없을 경우 기본 반환
    return '이 효과에 대한 자세한 설명이 없습니다.';
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
