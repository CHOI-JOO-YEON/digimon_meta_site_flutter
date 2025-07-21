import 'dart:math';

import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';

import '../../model/card.dart';
import '../../model/deck-build.dart';

class DeckStat extends StatelessWidget {
  final DeckBuild deck;
  final Color? textColor;
  final Color? barColor;
  final Color? backGroundColor;
  final double? radius;

  const DeckStat(
      {super.key,
      required this.deck,
      this.textColor,
      this.barColor,
      this.backGroundColor,
      this.radius,
      });

  @override
  Widget build(BuildContext context) {
    Map<String, int> cardCounts = _calculateCardCounts();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      List<Widget> indicators = cardCounts.entries.map((entry) {
        return _buildCardTypeIndicator(entry.key, entry.value,
            constraints.maxWidth, constraints.maxHeight);
      }).toList();
      return Container(
        height: constraints.maxHeight,
        decoration: BoxDecoration(
          gradient: backGroundColor != null 
            ? null 
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFF8FAFC),
                ],
              ),
          color: backGroundColor,
          borderRadius: BorderRadius.circular(radius ?? 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(constraints.maxHeight * 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: indicators,
            ),
          ),
        ),
      );
    });
  }

  Map<String, int> _calculateCardCounts() {
    Map<String, int> counts = {
      '-': 0,
      '2': 0,
      '3': 0,
      '4': 0,
      '5': 0,
      '6': 0,
      '7': 0,
      'T': 0,
      'O': 0,
    };

    for (var card in deck.deckMap.keys) {
      if (card.lv == 0) {
        counts['-'] = counts['-']! + deck.deckMap[card]!;
      } else if (card.lv == 2) {
        counts['2'] = counts['2']! + deck.deckMap[card]!;
      } else if (card.lv != null && card.lv! >= 3 && card.lv! <= 7) {
        counts['${card.lv}'] = counts['${card.lv}']! + deck.deckMap[card]!;
      } else if (card.cardType == 'TAMER') {
        counts['T'] = counts['T']! + deck.deckMap[card]!;
      } else if (card.cardType == 'OPTION') {
        counts['O'] = counts['O']! + deck.deckMap[card]!;
      }
    }
    for (var card in deck.tamaMap.keys) {
      if (card.lv == 0) {
        counts['-'] = counts['-']! + deck.tamaMap[card]!;
      } else if (card.lv == 2) {
        counts['2'] = counts['2']! + deck.tamaMap[card]!;
      } else if (card.lv != null && card.lv! >= 3 && card.lv! <= 7) {
        counts['${card.lv}'] = counts['${card.lv}']! + deck.tamaMap[card]!;
      } else if (card.cardType == 'TAMER') {
        counts['T'] = counts['T']! + deck.tamaMap[card]!;
      } else if (card.cardType == 'OPTION') {
        counts['O'] = counts['O']! + deck.tamaMap[card]!;
      }
    }
    return counts;
  }

  Widget _buildCardTypeIndicator(
      String cardType, int count, double width, double height) {
    final double barMaxHeight = height * 0.5;
    final double barHeight = min(barMaxHeight, (count / 24) * barMaxHeight);
    return Builder(builder: (context) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: height * 0.2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                      fontSize: height * 0.1,
                      fontFamily: 'JalnanGothic',
                      color: textColor ?? Colors.black),
                ),
              ),
            ),
            SizedBox(
              height: barMaxHeight,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: width * 0.01, right: width * 0.01),
                      child: Container(
                        width: double.infinity,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: barColor ?? Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                radius??SizeService.roundRadius(context)),
                            topRight: Radius.circular(
                                radius??SizeService.roundRadius(context)),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  cardType,
                  style: TextStyle(
                      fontSize: height * 0.1,
                      fontFamily: 'JalnanGothic',
                      color: textColor ?? Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
