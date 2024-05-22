import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/card.dart';
import '../../model/deck.dart';

class DeckStat extends StatelessWidget {
  final Deck deck;
  final Color? textColor;
  final Color? barColor;
  final Color? backGroundColor;

  const DeckStat(
      {super.key,
      required this.deck,
      this.textColor,
      this.barColor,
      this.backGroundColor});

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
            borderRadius: BorderRadius.circular(5),
            color: backGroundColor ?? Theme.of(context).cardColor),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(constraints.maxHeight * 0.05),
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
      'Lv-': 0,
      'Lv2': 0,
      'Lv3': 0,
      'Lv4': 0,
      'Lv5': 0,
      'Lv6': 0,
      'Lv7': 0,
      'TM': 0,
      'OP': 0,
    };

    for (var card in deck.deckMap.keys) {
      if (card.lv == 0) {
        counts['Lv-'] = counts['Lv-']! + deck.deckMap[card]!;
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
        counts['Lv-'] = counts['Lv-']! + deck.tamaMap[card]!;
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
                    child: Container(
                      width: double.infinity,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor ?? Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(width * 0.02),
                          topRight: Radius.circular(width * 0.02),
                        ),
                        // border: Border.all(color: Colors.white),
                      ),
                      alignment: Alignment.bottomCenter,
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
                      fontSize: height * 0.1, fontFamily: 'JalnanGothic'),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
