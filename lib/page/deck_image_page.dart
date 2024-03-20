import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;
import '../model/card.dart';
import '../model/deck.dart';
import '../widget/deck/deck_stat_view.dart';

@RoutePage()
class DeckImagePage extends StatefulWidget {
  final Deck deck;
  const DeckImagePage({super.key, required this.deck});

  @override
  State<DeckImagePage> createState() => _DeckImagePageState();
}

class _DeckImagePageState extends State<DeckImagePage> {
  Color selectedColor = const Color(0x66c8c8c8); // 초기 색상 설정

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    GlobalKey globalKey = GlobalKey();


    Future<void> captureAndDownloadImage(BuildContext context) async {
      try {
        RenderRepaintBoundary boundary = globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 1.5);
        ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
        final blob = html.Blob([byteData!.buffer.asUint8List()], 'image/png','native');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', '${widget.deck.deckName}.png')
          ..click();

        html.Url.revokeObjectUrl(url);
      } catch (e) {
        print(e);
      }
    }


    List<DigimonCard> displayDecks =
    _generateDisplayList(widget.deck.deckCards, widget.deck.deckMap);
    List<DigimonCard> displayTamas =
    _generateDisplayList(widget.deck.tamaCards, widget.deck.tamaMap);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 960,
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('${widget.deck.deckName} 이미지 내보내기',style: const TextStyle(fontFamily: 'JalnanGothic')),
              actions: [
                IconButton(onPressed: ()=>_showColorPicker(), icon: Icon(Icons.color_lens_outlined)),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => captureAndDownloadImage(context),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 960,
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: globalKey,
                child: Container(
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                        color:  selectedColor,
                        // color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(widget.deck.deckName,
                                        style: TextStyle(fontSize: 25,fontFamily: 'JalnanGothic')),
                                  )),
                              Expanded(flex: 1, child: SizedBox(height: 150, child: DeckStat(deck: widget.deck))),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          _buildGridView(
                              context, displayTamas, 10, Theme.of(context).cardColor, '디지타마 덱'),
                          const SizedBox(
                            height: 5,
                          ),
                          _buildGridView(
                              context, displayDecks, 10, Theme.of(context).cardColor, '메인 덱'),
                          // deckCards를 표시
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DigimonCard> _generateDisplayList(
      List<DigimonCard> cards, Map<DigimonCard, int> map) {
    List<DigimonCard> displayList = [];
    for (var card in cards) {
      int count = map[card] ?? 0;
      for (int i = 0; i < count; i++) {
        displayList.add(card);
      }
    }
    return displayList;
  }

  Widget _buildGridView(BuildContext context, List<DigimonCard> cards,
      int crossAxisCount, Color backColor, String name) {
    return Container(
      decoration: BoxDecoration(
          color: backColor, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(name, style: const TextStyle(fontFamily: 'JalnanGothic'),),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // 가로에 아이템 개수 설정
                childAspectRatio: 0.715,
              ),
              physics: NeverScrollableScrollPhysics(),
              // 스크롤 비활성화
              shrinkWrap: true,
              // 자식의 크기에 맞춤
              itemCount: cards.length,
              itemBuilder: (context, index) {
                // return Image.memory(
                //   cards[index].compressedImg!,
                //   fit: BoxFit.contain,
                // );'
                return Image.network(
                  cards[index].smallImgUrl ?? '',
                  fit: BoxFit.contain,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
//
// class DeckImagePage extends StatelessWidget {
//   final Deck deck;
//
//   const DeckImagePage({super.key, required this.deck});
//
//   @override
//   Widget build(BuildContext context) {
//     GlobalKey globalKey = GlobalKey();
//
//
//     Future<void> captureAndDownloadImage(BuildContext context) async {
//       try {
//         RenderRepaintBoundary boundary = globalKey.currentContext!
//             .findRenderObject() as RenderRepaintBoundary;
//         ui.Image image = await boundary.toImage(pixelRatio: 1);
//         ByteData? byteData =
//             await image.toByteData(format: ui.ImageByteFormat.png);
//         final blob = html.Blob([byteData!.buffer.asUint8List()], 'image/png');
//         final url = html.Url.createObjectUrlFromBlob(blob);
//
//         final anchor = html.AnchorElement(href: url)
//           ..setAttribute('download', '${deck.deckName}.png')
//           ..click();
//
//         html.Url.revokeObjectUrl(url);
//       } catch (e) {
//         print(e);
//       }
//     }
//
//
//     List<DigimonCard> displayDecks =
//         _generateDisplayList(deck.deckCards, deck.deckMap);
//     List<DigimonCard> displayTamas =
//         _generateDisplayList(deck.tamaCards, deck.tamaMap);
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: Align(
//           alignment: Alignment.center,
//           child: SizedBox(
//             width: 960,
//             child: AppBar(
//               backgroundColor: Theme.of(context).colorScheme.background,
//               title: Text('${deck.deckName} 이미지 내보내기',style: const TextStyle(fontFamily: 'JalnanGothic')),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.download),
//                   onPressed: () => captureAndDownloadImage(context),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Align(
//           alignment: Alignment.topCenter,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SizedBox(
//             width: 960,
//             child: SingleChildScrollView(
//               child: RepaintBoundary(
//                 key: globalKey,
//                 child: Container(
//                   color: Colors.white,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color:  Theme.of(context).splashColor,
//                         // color: Colors.blue[100],
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                   flex: 1,
//                                   child: Center(
//                                     child: Text(deck.deckName,
//                                         style: TextStyle(fontSize: 25,fontFamily: 'JalnanGothic')),
//                                   )),
//                               Expanded(flex: 1, child: SizedBox(height: 150, child: DeckStat(deck: deck))),
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           _buildGridView(
//                               context, displayTamas, 10, Theme.of(context).cardColor, '디지타마 덱'),
//                           const SizedBox(
//                             height: 5,
//                           ),
//                           _buildGridView(
//                               context, displayDecks, 10, Theme.of(context).cardColor, '메인 덱'),
//                           // deckCards를 표시
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<DigimonCard> _generateDisplayList(
//       List<DigimonCard> cards, Map<DigimonCard, int> map) {
//     List<DigimonCard> displayList = [];
//     for (var card in cards) {
//       int count = map[card] ?? 0;
//       for (int i = 0; i < count; i++) {
//         displayList.add(card);
//       }
//     }
//     return displayList;
//   }
//
//   Widget _buildGridView(BuildContext context, List<DigimonCard> cards,
//       int crossAxisCount, Color backColor, String name) {
//     return Container(
//       decoration: BoxDecoration(
//           color: backColor, borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Text(name, style: const TextStyle(fontFamily: 'JalnanGothic'),),
//             GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount, // 가로에 아이템 개수 설정
//                 childAspectRatio: 0.715,
//               ),
//               physics: NeverScrollableScrollPhysics(),
//               // 스크롤 비활성화
//               shrinkWrap: true,
//               // 자식의 크기에 맞춤
//               itemCount: cards.length,
//               itemBuilder: (context, index) {
//                 // return Image.memory(
//                 //   cards[index].compressedImg!,
//                 //   fit: BoxFit.contain,
//                 // );'
//                 return Image.network(
//                   cards[index].smallImgUrl ?? '',
//                   fit: BoxFit.contain,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
