import 'dart:math';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'dart:ui' as ui;
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
  Color backGroundColor = Color.fromRGBO(233, 233, 233, 1);
  Color textColor = Colors.black;
  Color cardColor = Colors.white;
  Color barColor = const Color(0xff1a237e);
  bool isHorizontal = false;
  final GlobalKey gridKey = GlobalKey();
  DigimonCard? _selectedCard;
  double size = 1000;
  double horizontalSize = 1650;

  @override
  void initState() {
    super.initState();
    if (widget.deck.deckCards.isEmpty) {
      _selectedCard = DigimonCard(isEn: false);
    } else {
      _selectedCard = widget.deck.deckCards.first;
    }

  }



  void _showColorPicker() {
    List<Color> exampleColors = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.black,
      Colors.purple,
      Colors.white,
      const Color(0x66c8c8c8),
      const Color(0xff1a237e)
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('색상 선택'),
          content: SingleChildScrollView(
            // shrinkWrap: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorSelector('배경 색상', backGroundColor, exampleColors,
                    (Color color) {
                  setState(() {
                    backGroundColor = color;
                  });
                }),
                Divider(),
                _buildColorSelector('텍스트 색상', textColor, exampleColors,
                    (Color color) {
                  setState(() {
                    textColor = color;
                  });
                }),
                Divider(),
                _buildColorSelector('카드 색상', cardColor, exampleColors,
                    (Color color) {
                  setState(() {
                    cardColor = color;
                  });
                }),
                Divider(),
                _buildColorSelector('바 색상', barColor, exampleColors,
                    (Color color) {
                  setState(() {
                    barColor = color;
                  });
                }),
              ],
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

  Widget _buildColorSelector(
    String title,
    Color selectedColor,
    List<Color> colors,
    ValueChanged<Color> onColorSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            ...colors.map((color) {
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
            GestureDetector(
              onTap: () async {
                Color pickedColor = selectedColor;
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('커스텀 색상 선택'),
                      content: SingleChildScrollView(
                        child: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            final TextEditingController rController =
                                TextEditingController(
                                    text: pickedColor.red.toString());
                            final TextEditingController gController =
                                TextEditingController(
                                    text: pickedColor.green.toString());
                            final TextEditingController bController =
                                TextEditingController(
                                    text: pickedColor.blue.toString());

                            final FocusNode rFocusNode = FocusNode();
                            final FocusNode gFocusNode = FocusNode();
                            final FocusNode bFocusNode = FocusNode();

                            void updateColor() {
                              int r = int.tryParse(rController.text) ?? 0;
                              int g = int.tryParse(gController.text) ?? 0;
                              int b = int.tryParse(bController.text) ?? 0;
                              setState(() {
                                pickedColor = Color.fromRGBO(r, g, b, 1);
                              });
                            }

                            return Column(
                              children: [
                                ColorPicker(
                                  pickerColor: pickedColor,
                                  onColorChanged: (Color color) {
                                    pickedColor = color;
                                    rController.text = color.red.toString();
                                    gController.text = color.green.toString();
                                    bController.text = color.blue.toString();
                                    onColorSelected(pickedColor);
                                  },
                                  pickerAreaHeightPercent: 0.8,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (!hasFocus) updateColor();
                                        },
                                        child: TextField(
                                          controller: rController,
                                          focusNode: rFocusNode,
                                          decoration: InputDecoration(
                                            labelText: 'R',
                                          ),
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) => updateColor(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (!hasFocus) updateColor();
                                        },
                                        child: TextField(
                                          controller: gController,
                                          focusNode: gFocusNode,
                                          decoration: InputDecoration(
                                            labelText: 'G',
                                          ),
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) => updateColor(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (!hasFocus) updateColor();
                                        },
                                        child: TextField(
                                          controller: bController,
                                          focusNode: bFocusNode,
                                          decoration: InputDecoration(
                                            labelText: 'B',
                                          ),
                                          keyboardType: TextInputType.number,
                                          onSubmitted: (_) => updateColor(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
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
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey = GlobalKey();
    Future<void> captureAndDownloadImage(BuildContext context) async {
      try {
        RenderRepaintBoundary boundary = globalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;

        final boundarySize = boundary.size;

        double targetWidth = isHorizontal?horizontalSize:size;


        var pixelRatio = targetWidth / boundarySize.width;

        ui.Image image = await boundary.toImage(
          pixelRatio: pixelRatio,
        );

        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        await WebImageDownloader.downloadImageFromUInt8List(
            uInt8List: byteData!.buffer.asUint8List(),
            name: '${widget.deck.deckName}.png',
            imageType: ImageType.png);
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 1000,
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('이미지 내보내기',
                  style: const TextStyle(fontFamily: 'JalnanGothic')),
              actions: [
                IconButton(
                    onPressed: () => _showColorPicker(),
                    icon: Icon(Icons.color_lens_outlined)),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => captureAndDownloadImage(context),
                ),
                Text('대표 카드 보이기'),
                Switch(
                  inactiveThumbColor: Colors.red, // 비활성화 시 thumb 색상
                  value: isHorizontal,
                  onChanged: (value) {
                    setState(() {
                      isHorizontal = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth =
              min(constraints.maxWidth, isHorizontal ? horizontalSize : size);
          double scaleFactor =
              screenWidth / (isHorizontal ? horizontalSize : size);
          return SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                key: globalKey,
                child: Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(8 * scaleFactor),
                  decoration: BoxDecoration(
                    color: backGroundColor,
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  child: Column(
                    children: [
                      _deckImageHeaderWidget(scaleFactor),
                      Row(
                        children: [
                          if (isHorizontal)
                            SizedBox(
                              width: 640 * scaleFactor,
                              child: Image.network(
                                  fit: BoxFit.contain,
                                  _selectedCard?.imgUrl ?? ''),
                            ),

                          if (isHorizontal)
                            SizedBox(
                              width: 10 * scaleFactor,
                            ),
                          SizedBox(
                            width: 984 * scaleFactor,
                            child: _deckImageCenterWidget(scaleFactor, context),
                          ),
                        ],
                      ),
                      _deckImageFooterWidget(scaleFactor)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _deckImageHeaderWidget(double scaleFactor) {
    return Row(
      children: [
        SizedBox(
          width: (isHorizontal ? 1142 : 492) * scaleFactor,
          child: Center(
            child: Text(
              widget.deck.deckName,
              style: TextStyle(
                  fontSize: 25 * scaleFactor,
                  fontFamily: 'JalnanGothic',
                  color: textColor),
            ),
          ),
        ),
        SizedBox(
          width: 492 * scaleFactor,
          child: SizedBox(
            height: 150 * scaleFactor,
            child: DeckStat(
                deck: widget.deck,
                textColor: textColor,
                barColor: barColor,
                backGroundColor: cardColor),
          ),
        ),
      ],
    );
  }

  Widget _deckImageFooterWidget(double scaleFactor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Image created using Digimon Meta (digimon-meta.site)',
          style: TextStyle(fontSize: 10 * scaleFactor, color: textColor),
        )
      ],
    );
  }

  Widget _deckImageCenterWidget(double scaleFactor, BuildContext context) {
    List<DigimonCard> displayDecks =
        _generateDisplayList(widget.deck.deckCards, widget.deck.deckMap);
    List<DigimonCard> displayTamas =
        _generateDisplayList(widget.deck.tamaCards, widget.deck.tamaMap);
    return Column(
      key: gridKey,
      children: [
        SizedBox(height: 5 * scaleFactor),
        _buildGridView(
            context, displayTamas, 10, cardColor, '디지타마 덱', scaleFactor),
        SizedBox(height: 5 * scaleFactor),
        _buildGridView(
            context, displayDecks, 10, cardColor, '메인 덱', scaleFactor),
        SizedBox(height: 5 * scaleFactor),
      ],
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List<DigimonCard> cards,
    int crossAxisCount,
    Color backColor,
    String name,
    double scaleFactor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(10 * scaleFactor),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0 * scaleFactor),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                  fontFamily: 'JalnanGothic',
                  fontSize: 16 * scaleFactor,
                  color: textColor),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.715,
              ),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _selectedCard = cards[index];
                    setState(() {});
                  },
                  child: Image.network(
                    cards[index].smallImgUrl ?? '',
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
