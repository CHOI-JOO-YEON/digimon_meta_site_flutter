import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/deck.dart';

class DeckCount extends StatelessWidget {
  final Deck deck;
  const DeckCount({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    // deckCount에 따른 색상 결정
    Color deckCountColor = deck.deckCount == 50 ? Colors.green : Colors.red;
    // tamaCount에 따른 색상 결정
    Color tamaCountColor = deck.tamaCount <= 5 ? Colors.green : Colors.red;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '덱',
                  style: TextStyle(fontSize: min(constraints.maxWidth/10,constraints.maxHeight/8), fontWeight: FontWeight.bold),
                ),
                Text(
                  '${deck.deckCount}/50',
                  style: TextStyle(color: deckCountColor, fontSize:min(constraints.maxWidth/10,constraints.maxHeight/8), fontWeight: FontWeight.bold),
                ),
                Text(
                  '디지타마 덱',
                  style: TextStyle(fontSize: min(constraints.maxWidth/10,constraints.maxHeight/8), fontWeight: FontWeight.bold),
                ),
                Text(
                  '${deck.tamaCount}/5',
                  style: TextStyle(color: tamaCountColor, fontSize: min(constraints.maxWidth/10,constraints.maxHeight/8), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

