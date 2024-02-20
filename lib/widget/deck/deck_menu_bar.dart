import 'dart:math';

import 'package:digimon_meta_site_flutter/page/deck_image_page.dart';
import 'package:flutter/material.dart';

import '../../model/deck.dart';

class DeckMenuBar extends StatefulWidget {
  final Deck deck;
  final Function() clear;
  const DeckMenuBar({super.key, required this.deck, required this.clear});

  @override
  State<DeckMenuBar> createState() => _DeckMenuBarState();
}

class _DeckMenuBarState extends State<DeckMenuBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // IconButton의 크기를 상위 위젯 크기에 맞추어 조정
      double iconButtonSize =
          min(constraints.maxWidth / 10, constraints.maxHeight / 2);
      double iconSize = iconButtonSize * 0.6; // IconButton 내부의 Icon 크기

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: iconButtonSize, height: iconButtonSize),
            child: IconButton(
              onPressed: () {
               widget.clear();
              },
              iconSize: iconSize,
              icon: const Icon(Icons.delete_forever),
              tooltip: '초기화',
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: iconButtonSize, height: iconButtonSize),
            child: IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: const Icon(Icons.save),
              tooltip: '저장',
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: iconButtonSize, height: iconButtonSize),
            child: IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: const Icon(Icons.download),
              tooltip: '가져오기',
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: iconButtonSize, height: iconButtonSize),
            child: IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: const Icon(Icons.upload),
              tooltip: '내보내기',
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: iconButtonSize, height: iconButtonSize),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeckImagePage(deck: widget.deck)),
                );
              },
              iconSize: iconSize,
              icon: const Icon(Icons.image),
              tooltip: '이미지 저장',
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                width: iconButtonSize, height: iconButtonSize),
            child: IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: const Icon(Icons.back_hand),
              tooltip: '랜덤패',
            ),
          ),
        ],
      );
    });
  }
}
