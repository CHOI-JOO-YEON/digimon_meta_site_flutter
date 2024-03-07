import 'dart:math';

import 'package:digimon_meta_site_flutter/model/deck.dart';
import 'package:digimon_meta_site_flutter/widget/card/card_widget.dart';
import 'package:digimon_meta_site_flutter/widget/stack_hand.dart';
import 'package:flutter/material.dart';

import '../model/card.dart';

class RandomHandWidget extends StatefulWidget {
  final Deck deck;

  const RandomHandWidget({super.key, required this.deck});

  @override
  State<RandomHandWidget> createState() => _RandomHandWidgetState();
}

class _RandomHandWidgetState extends State<RandomHandWidget> {
  List<DigimonCard> mainDeck = [];
  List<DigimonCard> tamaDeck = [];
  int deckCount = 0;
  int tamaCount = 0;

  List<DigimonCard> hands = [];
  List<DigimonCard> openTamas = [];
  List<DigimonCard> securities = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var entry in widget.deck.deckMap.entries) {
      for (int i = 0; i < entry.value; i++) {
        mainDeck.add(entry.key);
      }
    }
    mainDeck.shuffle(Random());

    for (var entry in widget.deck.tamaMap.entries) {
      for (int i = 0; i < entry.value; i++) {
        tamaDeck.add(entry.key);
      }
    }
    tamaDeck.shuffle(Random());
    init();
  }

  void init() {
    for (int i = 0; i < 5; i++) {
      hands.add(mainDeck[deckCount++]);
    }
    for (int i = 0; i < 5; i++) {
      securities.add(mainDeck[deckCount++]);
    }
    setState(() {});
  }

  void reset() {
    deckCount = 0;
    tamaCount = 0;
    hands = [];
    openTamas = [];
    securities = [];
    mainDeck.shuffle(Random());
    tamaDeck.shuffle(Random());
    init();
  }

  void draw() {
    if (deckCount < mainDeck.length - 1) {
      hands.add(mainDeck[deckCount++]);
      setState(() {});
    }
  }

  void openTama() {
    if (tamaCount < tamaDeck.length - 1) {
      openTamas.add(tamaDeck[tamaCount++]);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = (MediaQuery.of(context).size.width / 8);
    double cardHeight = cardWidth / 0.715;
    return Row(
      children: [
        ElevatedButton(onPressed: draw, child: Text('draw')),
        Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.red,
                      child: Stack(
                        children: securities.asMap().entries.map((entry) {
                          int index = entry.key;
                          String url = entry.value.smallImgUrl ?? '';
                          return Positioned(
                            top: (4-index) * (cardWidth/3),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Transform.rotate(
                                angle: -90 * 3.141592653589793238 / 180,
                                // 라디안으로 변환된 90도
                                origin: Offset(0,0),
                                // 회전 축을 조정합니다. 이 값을 조절해 보세요.
                                child: CustomCard(width: cardWidth,cardPressEvent: (card){},card: hands[index],),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )),
                Expanded(flex: 1, child: Container())
              ],
            )),
        // Expanded(
        //     flex: 5,
        //     child: GridView.builder(
        //       gridDelegate:
        //           SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        //       itemCount: hands.length,
        //       itemBuilder: (BuildContext context, int index) {
        //         return Image.network(
        //           hands[index].smallImgUrl ?? '',
        //           fit: BoxFit.contain,
        //         );
        //       },
        //     ))
        Expanded(flex: 5, child: Column(children: [
          StackHand(hands: hands),
          StackHand(hands: []),
        ],),)
      ],
    );
  }
}
