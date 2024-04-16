import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../enums/site_enum.dart';
import '../../../model/deck.dart';

class DeckViewerMenuBar extends StatefulWidget {
  final Deck deck;

  const DeckViewerMenuBar(
      {super.key,
      required this.deck,});

  @override
  State<DeckViewerMenuBar> createState() => _DeckViewerMenuBarState();
}

class _DeckViewerMenuBarState extends State<DeckViewerMenuBar> {


  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width*0.01,25);
    double iconSize  = min(MediaQuery.sizeOf(context).width*0.03,25);
    if(isPortrait) {
      fontSize*=2;
      iconSize*=1.2;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('작성자: ${widget.deck.author}',
              style: TextStyle(fontSize: fontSize),),
            Text(
              '덱 이름: ${widget.deck.deckName}',
              style: TextStyle(fontSize: fontSize
              // ,overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
