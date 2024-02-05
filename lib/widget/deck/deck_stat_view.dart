import 'dart:math';

import 'package:digimon_meta_site_flutter/widget/deck/deck_stat_bar.dart';
import 'package:flutter/material.dart';

import '../../model/card.dart';
import '../../model/deck.dart';

class DeckStat extends StatelessWidget {
  final Deck deck;

  const DeckStat({Key? key, required this.deck}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카드 유형별 개수를 계산합니다.
    Map<String, int> cardCounts = _calculateCardCounts();

    // 각 카드 유형별로 위젯을 구성합니다.

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      List<Widget> indicators = cardCounts.entries.map((entry) {
        return _buildCardTypeIndicator(entry.key, entry.value,
            constraints.maxWidth, constraints.maxHeight);
      }).toList();
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: indicators,
        ),
      );
    });
  }

  // 카드 유형별 개수를 계산하는 함수
  Map<String, int> _calculateCardCounts() {
    Map<String, int> counts = {
      'Lv-': 0,
      'Lv2': 0,
      'Lv3': 0,
      'Lv4': 0,
      'Lv5': 0,
      'Lv6': 0,
      'Lv7+': 0,
      'TM': 0,
      'OP': 0,
    };

    for (var card in deck.deckMap.keys) {
      if (card.lv == 0) {
        counts['Lv0'] = counts['Lv0']! + deck.deckMap[card]!;
      } else if (card.lv == 2) {
        counts['Lv2'] = counts['Lv2']! + deck.deckMap[card]!;
      } else if (card.lv != null && card.lv! >= 3 && card.lv! <= 7) {
        counts['Lv${card.lv}'] = counts['Lv${card.lv}']! + deck.deckMap[card]!;
      } else if (card.cardType == 'TAMER') {
        counts['TM'] = counts['TM']! + deck.deckMap[card]!;
      } else if (card.cardType == 'OPTION') {
        counts['OP'] = counts['OP']! + deck.deckMap[card]!;
      }
    }
    for (var card in deck.tamaMap.keys) {
      if (card.lv == 0) {
        counts['Lv0'] = counts['Lv0']! + deck.tamaMap[card]!;
      } else if (card.lv == 2) {
        counts['Lv2'] = counts['Lv2']! + deck.tamaMap[card]!;
      } else if (card.lv != null && card.lv! >= 3 && card.lv! <= 7) {
        counts['Lv${card.lv}'] = counts['Lv${card.lv}']! + deck.tamaMap[card]!;
      } else if (card.cardType == 'TAMER') {
        counts['TM'] = counts['TM']! + deck.tamaMap[card]!;
      } else if (card.cardType == 'OPTION') {
        counts['OP'] = counts['OP']! + deck.tamaMap[card]!;
      }
    }
    return counts;
  }

  // 각 카드 유형별 바와 숫자를 나타내는 위젯을 만드는 함수
  Widget _buildCardTypeIndicator(
      String cardType, int count, double width, double height) {
    // 전체 바의 높이를 정의합니다.
    final double barMaxHeight = height * 0.8; // 또는 원하는 최대 높이로 설정
    // 50장 기준으로 비율을 계산합니다.
    final double barHeight = min(barMaxHeight, (count / 30) * barMaxHeight);
    return Builder(builder: (context) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              count.toString(),
              // style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 4), // 숫자와 바 사이의 간격
            SizedBox(
              height: height * 0.4,
              child: Stack(
                children: [
                  Align(
                    child: Container(
                      width: double.infinity,
                      height: barHeight,
                      // 계산된 높이를 사용합니다.
                      decoration: BoxDecoration(
                        color: count > 0 ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white),
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                ],
              ),
            ),
            Text(
              cardType,
              // style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    });
  }
}
