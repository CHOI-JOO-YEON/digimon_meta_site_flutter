import 'dart:math';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/service/deck_image_color_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import '../model/card.dart';
import '../model/deck-build.dart';
import '../service/color_service.dart';
import '../widget/color_picker_bottom_sheet.dart';
import '../widget/deck/deck_stat_view.dart';

@RoutePage()
class DeckImagePage extends StatefulWidget {
  final DeckBuild deck;

  const DeckImagePage({super.key, required this.deck});

  @override
  State<DeckImagePage> createState() => _DeckImagePageState();
}

class _DeckImagePageState extends State<DeckImagePage> {
  DeckImageColorService deckImageColorService = DeckImageColorService();
  bool isHorizontal = false;
  bool showInfo = true;
  bool isQrShow = false;
  final GlobalKey gridKey = GlobalKey();
  DigimonCard? _selectedCard;
  double size = 1000;
  double horizontalSize = 0;
  String selectColorSetKey = "RED";
  double scaleFactor = 0;
  double bottomSheetScale = 0;

  @override
  void initState() {
    horizontalSize = size * 1.65;
    super.initState();
    if (widget.deck.deckCards.isEmpty) {
      _selectedCard = DigimonCard(isEn: false, localeCardData: []);
    } else {
      _selectedCard = widget.deck.deckCards.first;
    }
  }

  void _showColorSetsBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.grey[100],
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        List<String> colorKeys =
            deckImageColorService.selectableColorMap.keys.toList();
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0 * bottomSheetScale,
                    vertical: 10.0 * bottomSheetScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '컬러 테마 선택',
                      style: TextStyle(
                        fontSize: 18 * bottomSheetScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10 * bottomSheetScale),
                    Wrap(
                        spacing: 10.0 * bottomSheetScale, // 가로 간격
                        runSpacing: 10.0 * bottomSheetScale, // 세로 간격
                        children: [
                          ...List.generate(
                            colorKeys.length,
                            (index) {
                              String color = colorKeys[index];
                              Color buttonColor =
                                  ColorService.getColorFromString(color);
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectColorSetKey = color;
                                  });
                                },
                                child: Container(
                                  width: 40 * bottomSheetScale,
                                  height: 40 * bottomSheetScale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectColorSetKey == color
                                        ? buttonColor
                                        : buttonColor.withOpacity(0.3),
                                  ),
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectColorSetKey = 'custom';
                              });
                            },
                            child: Container(
                              width: 40 * bottomSheetScale,
                              height: 40 * bottomSheetScale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectColorSetKey == 'custom'
                                    ? Colors.pinkAccent
                                    : Colors.pinkAccent.withOpacity(0.3),
                              ),
                              child: Icon(
                                  size: 30 * bottomSheetScale,
                                  Icons.dashboard_customize_outlined),
                            ),
                          )
                        ]),
                    SizedBox(height: 20 * bottomSheetScale),
                    Divider(thickness: 2),
                    if (selectColorSetKey != 'custom')
                      Expanded(
                        child: ListView.builder(
                          itemCount: deckImageColorService
                              .selectableColorMap[selectColorSetKey]!.length,
                          itemBuilder: (context, index) {
                            var deckImageColor = deckImageColorService
                                .selectableColorMap[selectColorSetKey]![index];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  deckImageColorService
                                      .updateColor(deckImageColor);
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8.0 * bottomSheetScale),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '컬러 세트 ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16 * bottomSheetScale,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                deckImageColor.backGroundColor,
                                            shape: BoxShape.circle,
                                          ),
                                          width: 30 * bottomSheetScale,
                                          height: 30 * bottomSheetScale,
                                        ),
                                        SizedBox(width: 8 * bottomSheetScale),
                                        // 간격 추가
                                        Container(
                                          decoration: BoxDecoration(
                                            color: deckImageColor.textColor,
                                            shape: BoxShape.circle,
                                          ),
                                          width: 30 * bottomSheetScale,
                                          height: 30 * bottomSheetScale,
                                        ),
                                        SizedBox(width: 8 * bottomSheetScale),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: deckImageColor.cardColor,
                                            shape: BoxShape.circle,
                                          ),
                                          width: 30 * bottomSheetScale,
                                          height: 30 * bottomSheetScale,
                                        ),
                                        SizedBox(width: 8 * bottomSheetScale),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: deckImageColor.barColor,
                                            shape: BoxShape.circle,
                                          ),
                                          width: 30 * bottomSheetScale,
                                          height: 30 * bottomSheetScale,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectColorSetKey == 'custom')
                      Expanded(
                        child: ColorPickerBottomSheet(
                          scaleFactor: bottomSheetScale,
                          onColorChanged: (color) {
                            setState(() {});
                          },
                        ),
                      )
                  ],
                ),
              ),
            );
          },
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

        final boundarySize = boundary.size;

        double targetWidth = isHorizontal ? horizontalSize : size;

        var pixelRatio = targetWidth / boundarySize.width;
        pixelRatio *= 1.3;

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
            width: size,
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text('이미지 내보내기',
                  style: const TextStyle(fontFamily: 'JalnanGothic')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => captureAndDownloadImage(context),
                ),
                PopupMenuButton<String>(
                  tooltip: '메뉴',
                  icon: Icon(Icons.settings),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      child: Text('색상 변경'),
                      onTap: () => _showColorSetsBottomSheet(),
                    ),
                    PopupMenuItem<String>(
                        child: Text('색상 초기화'),
                        onTap: () {
                          setState(() {
                            deckImageColorService.resetColor();
                          });
                        }),
                    PopupMenuItem<String>(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('덱 정보 표시'),
                              Switch(
                                inactiveThumbColor: Colors.red,
                                value: showInfo,
                                onChanged: (value) {
                                  setState(() {
                                    showInfo = value;
                                  });
                                  this.setState(() {
                                    showInfo = value;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    PopupMenuItem<String>(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('대표 카드 표시'),
                              Switch(
                                inactiveThumbColor: Colors.red,
                                value: isHorizontal,
                                onChanged: (value) {
                                  setState(() {
                                    isHorizontal = value;
                                  });
                                  this.setState(() {
                                    isHorizontal = value;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    PopupMenuItem<String>(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('QR 코드 표시(개발 중)'),
                              Switch(
                                inactiveThumbColor: Colors.red,
                                value: isQrShow,
                                onChanged: (value) {
                                  setState(() {
                                    isQrShow = value;
                                  });
                                  this.setState(() {
                                    isQrShow = value;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          double maxWidth = MediaQuery.of(context).size.width;
          bottomSheetScale = isPortrait
              ? (maxWidth * 2) / size
              : (maxWidth * 0.6) / size;
          double screenWidth =
              min(maxWidth, isHorizontal ? horizontalSize : size);
          scaleFactor = screenWidth / (isHorizontal ? horizontalSize : size);
          return SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                key: globalKey,
                child: Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(8 * scaleFactor),
                  decoration: BoxDecoration(
                    color: deckImageColorService
                        .selectedDeckImageColor.backGroundColor,
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  child: Column(
                    children: [
                      if (showInfo) _deckImageHeaderWidget(scaleFactor),
                      Row(
                        children: [
                          if (isHorizontal)
                            SizedBox(
                              width: 610 * scaleFactor,
                              child: Image.network(
                                  fit: BoxFit.contain,
                                  _selectedCard?.getDisplayImgUrl() ?? ''),
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
          width: ((isHorizontal ? 950 : 328) + (isQrShow ? 0 : 164)) * scaleFactor,
          child: Center(
            child: Text(
              widget.deck.deckName,
              style: TextStyle(
                  fontSize: 25 * scaleFactor,
                  fontFamily: 'JalnanGothic',
                  color:
                      deckImageColorService.selectedDeckImageColor.textColor),
            ),
          ),
        ),
        SizedBox(
          width: 492 * scaleFactor,
          height: 150 * scaleFactor,
          child: DeckStat(
              deck: widget.deck,
              textColor:
                  deckImageColorService.selectedDeckImageColor.textColor,
              barColor: deckImageColorService.selectedDeckImageColor.barColor,
              backGroundColor:
                  deckImageColorService.selectedDeckImageColor.cardColor),
        ),
        if (isQrShow)
        SizedBox(width: 10 * scaleFactor,),
        if (isQrShow)
          SizedBox(
            width: 154 * scaleFactor,
            height: 150 * scaleFactor,
            child: QrImageView(
              padding: EdgeInsets.all(2 * scaleFactor),
              data: widget.deck.getQrUrl(),
              // embeddedImage: AssetImage('assets/images/img.png'),
              // embeddedImageStyle: QrEmbeddedImageStyle(
              //   size: Size(40 * scaleFactor, 40 * scaleFactor
              //   ), // 이미지 크기
              // ),
              version: QrVersions.auto,
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
          'Image created using DGCHub (dgchub.com)',
          style: TextStyle(
              fontSize: 10 * scaleFactor,
              color: deckImageColorService.selectedDeckImageColor.textColor),
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
            context,
            displayTamas,
            10,
            deckImageColorService.selectedDeckImageColor.cardColor,
            '디지타마 덱',
            scaleFactor),
        SizedBox(height: 5 * scaleFactor),
        _buildGridView(
            context,
            displayDecks,
            10,
            deckImageColorService.selectedDeckImageColor.cardColor,
            '메인 덱',
            scaleFactor),
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
            // Text(
            //   name,
            //   style: TextStyle(
            //       fontFamily: 'JalnanGothic',
            //       fontSize: 16 * scaleFactor,
            //       color:
            //           deckImageColorService.selectedDeckImageColor.textColor),
            // ),
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
                    cards[index].getDisplaySmallImgUrl() ?? '',
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
