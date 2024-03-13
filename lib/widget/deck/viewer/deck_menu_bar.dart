import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        SiteName selectedButton = SiteName.values.first;
        TextEditingController textEditingController = TextEditingController(
          text: selectedButton.ExportToSiteDeckCode(widget.deck), // 초기값 설정
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Export to'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SiteName.values.map((siteName) {
                        String name = siteName.toString().split('.').last;
                        return Expanded(
                          child: ListTile(
                            title: Text(name),
                            leading: Radio<SiteName>(
                              value: siteName,
                              groupValue: selectedButton,
                              onChanged: (SiteName? value) {
                                setState(() {
                                  selectedButton = value!;
                                  textEditingController.text =
                                      selectedButton.ExportToSiteDeckCode(
                                          widget.deck);
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: textEditingController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Paste your deck.',
                      ),
                      enabled: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: textEditingController.text))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width*0.009,15);
    if(isPortrait) {
      fontSize*=2;
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double iconButtonSize =
          min(constraints.maxWidth / 10, constraints.maxHeight / 2);
      double iconSize = iconButtonSize; // IconButton 내부의 Icon 크기
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('작성자: ${widget.deck.author}',
                      style: TextStyle(fontSize: fontSize),),
                    Text(
                      '덱 이름: ${widget.deck.deckName}',
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              )),
          Expanded(
            flex: 1,
            child: Consumer<UserProvider>(builder: (BuildContext context,
                UserProvider userProvider, Widget? child) {
              bool hasManagerRole = userProvider.hasManagerRole(); // 권한 확인
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showExportDialog(context),
                      iconSize: iconSize,
                      icon: const Icon(Icons.upload),
                      tooltip: '내보내기',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        context.router.push(DeckImageRoute(deck: widget.deck));
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.image),
                      tooltip: '이미지 저장',
                    ),
                  ),
                  if (hasManagerRole) // 권한 체크 조건
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: iconButtonSize, height: iconButtonSize),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await DeckService().exportToTTSFile(widget.deck);
                        },
                        iconSize: iconSize,
                        icon: const Icon(Icons.videogame_asset_outlined),
                        // 예시 아이콘, 실제 사용할 아이콘으로 변경
                        tooltip: 'TTS 파일 내보내기', // 툴팁 내용도 상황에 맞게 변경
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      );
    });
  }
}
