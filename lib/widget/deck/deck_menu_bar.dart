import 'package:digimon_meta_site_flutter/page/deck_image_page.dart';
import 'package:flutter/material.dart';

import '../../model/deck.dart';

class DeckMenuBar extends StatefulWidget {
  final Deck deck;

  const DeckMenuBar({super.key, required this.deck});

  @override
  State<DeckMenuBar> createState() => _DeckMenuBarState();
}

class _DeckMenuBarState extends State<DeckMenuBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton( onPressed: () {
          widget.deck.clear();

        }, icon: const Icon(Icons.delete_forever), tooltip: '초기화',),
        IconButton( onPressed: () {}, icon: const Icon(Icons.save), tooltip: '저장',),
        IconButton( onPressed: () {}, icon: const Icon(Icons.download), tooltip: '가져오기',),
        IconButton( onPressed: () {}, icon: const Icon(Icons.upload), tooltip: '내보내기',),
        IconButton( onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> DeckImagePage(deck: widget.deck)));


        }, icon: const Icon(Icons.image), tooltip: '이미지 저장',),
        IconButton( onPressed: () {}, icon: const Icon(Icons.back_hand), tooltip: '랜덤패',),
      ],
    );
  }
}
