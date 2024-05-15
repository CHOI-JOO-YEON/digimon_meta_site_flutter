import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    if(isPortrait) {
      fontSize*=2;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.deck.deckName}',
              style: TextStyle(fontSize: fontSize
                // ,overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('${widget.deck.author}#${(widget.deck.authorId!-3).toString().padLeft(4,'0')}',
              style: TextStyle(fontSize: fontSize*0.8),),

          ],
        ),
      ),
    );
  }
}
