import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/deck-build.dart';

class DeckCount extends StatelessWidget {
  final DeckBuild deck;
  const DeckCount({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width*0.009,15);
    if(isPortrait) {
      fontSize*=2;
    }
    Color deckCountColor = deck.deckCount == 50 ? Colors.green : Colors.red;
    Color tamaCountColor = deck.tamaCount <= 5 ? Colors.green : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '덱: ',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        // SizedBox(width: 20,),
        Text(
          '${deck.deckCount}/50',
          style: TextStyle(color: deckCountColor, fontSize:fontSize, fontWeight: FontWeight.bold),
        ),
        // SizedBox(width: 100,),
        Text(
          '디지타마 덱: ',
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        // SizedBox(width: 20,),
        Text(
          '${deck.tamaCount}/5',
          style: TextStyle(color: tamaCountColor, fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

