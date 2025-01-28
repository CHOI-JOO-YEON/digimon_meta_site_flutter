import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../model/deck-build.dart';

class DeckCount extends StatelessWidget {
  final DeckBuild deck;

  const DeckCount({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    Color deckCountColor = deck.deckCount == 50 ? Colors.green : Colors.red;
    Color tamaCountColor = deck.tamaCount <= 5 ? Colors.green : Colors.red;

    return ResponsiveRowColumn(
      layout: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
          ? ResponsiveRowColumnType.COLUMN
          : ResponsiveRowColumnType.ROW,
      rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
      columnCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveRowColumnItem(
          child: Text(
            '덱: ${deck.deckCount}/50',
            style: TextStyle(
              fontSize: SizeService.smallFontSize(context),
              fontWeight: FontWeight.bold,
              color: deckCountColor,
            ),
          ),
        ),
        ResponsiveRowColumnItem(
          child: Text(
            '디지타마 덱: ${deck.tamaCount}/5',
            style: TextStyle(
              fontSize: SizeService.smallFontSize(context),
              fontWeight: FontWeight.bold,
              color: tamaCountColor,
            ),
          ),
        ),
      ],
    );
  }
}

