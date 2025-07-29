import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../model/deck-build.dart';
import '../deck_count_widget.dart';

class DeckViewerMenuBar extends StatefulWidget {
  final DeckBuild deck;

  const DeckViewerMenuBar(
      {super.key,
      required this.deck,});

  @override
  State<DeckViewerMenuBar> createState() => _DeckViewerMenuBarState();
}

class _DeckViewerMenuBarState extends State<DeckViewerMenuBar> {


  @override
  Widget build(BuildContext context) {


    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.deck.author ?? 'Unknown'}${widget.deck.authorId != null ? '#${(widget.deck.authorId! - 3).toString().padLeft(4, '0')}' : ''}',
                      style: TextStyle(fontSize: SizeService.smallFontSize(context)),),
                    Text(
                      widget.deck.deckName ?? 'Untitled Deck',
                      style: TextStyle(fontSize: SizeService.bodyFontSize(context)
                        // ,overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: SizedBox(
                    width: constraints.maxWidth,
                    child: DeckCount(
                      deck: widget.deck,
                    )))
          ],
        );
      }
    );
  }
}
