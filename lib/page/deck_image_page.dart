import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;
import '../model/card.dart';
import '../model/deck.dart';

class DeckImagePage extends StatelessWidget {
  final Deck deck;

  const DeckImagePage({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    GlobalKey _globalKey = GlobalKey();

    Future<void> _captureAndDownloadImage(BuildContext context) async {
      try {
        RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final blob = html.Blob([byteData!.buffer.asUint8List()], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);

        // 다운로드 링크 생성
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'deck_image.png')
          ..click();

        // URL 해제
        html.Url.revokeObjectUrl(url);
      } catch (e) {
        // 에러 처리
        print(e);
      }
    }
    List<DigimonCard> displayDecks = _generateDisplayList(deck.deckCards, deck.deckMap);
    List<DigimonCard> displayTamas = _generateDisplayList(deck.tamaCards, deck.tamaMap);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _captureAndDownloadImage(context),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width/2,
          child: SingleChildScrollView( // 전체를 스크롤 가능하게 함
            child: Column(
              children: [
                _buildGridView(context, displayDecks, 10), // deckCards를 표시
                _buildGridView(context, displayTamas, 10), // tamaCards를 표시
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DigimonCard> _generateDisplayList(List<DigimonCard> cards, Map<DigimonCard, int> map) {
    List<DigimonCard> displayList = [];
    for (var card in cards) {
      int count = map[card] ?? 0;
      for (int i = 0; i < count; i++) {
        displayList.add(card);
      }
    }
    return displayList;
  }

  Widget _buildGridView(BuildContext context, List<DigimonCard> cards, int crossAxisCount) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // 가로에 아이템 개수 설정
        childAspectRatio: 0.715,
      ),
      physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
      shrinkWrap: true, // 자식의 크기에 맞춤
      itemCount: cards.length,
      itemBuilder: (context, index) {
        // return Image.memory(
        //   cards[index].compressedImg!,
        //   fit: BoxFit.contain,
        // );'
        return Image.network(cards[index].imgUrl??'',fit: BoxFit.contain,);
      },
    );
  }
}