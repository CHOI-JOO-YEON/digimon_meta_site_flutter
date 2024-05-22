
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../enums/site_enum.dart';
import '../../../model/deck.dart';
import '../../../model/deck_response_dto.dart';
import '../../../provider/user_provider.dart';
import '../../../router.dart';
import '../../../service/deck_service.dart';

class DeckMenuButtons extends StatefulWidget {
  final Deck deck;
  const DeckMenuButtons({super.key, required this.deck});

  @override
  State<DeckMenuButtons> createState() => _DeckMenuButtonsState();
}

class _DeckMenuButtonsState extends State<DeckMenuButtons> {


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
                        String name = siteName.getName;
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
  void _showDeckCopyDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('덱 복사'),
          content: Text('이 덱을 카피하여 새로운 덱을 만들겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {

                Deck deck = Deck.deck(widget.deck);
                Navigator.of(context).pop();

                context.navigateTo(DeckBuilderRoute(deck: deck));
              },
            ),
          ],
        );
      },
    );
  }
  void showDeckReceiptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('대회 제출용 레시피 다운로드'),
          content:const SizedBox(
            width: 300,
            child: Text(
              '* 덱은 31종, 디지타마는 5종까지만 레시피에 기입되며, 이를 넘는 카드 종류는 레시피에 반영되지 않습니다.\n* 레시피 불일치로 발생하는 문제는 책임지지 않으며, 제출 전 꼭 확인 바랍니다.',
              softWrap: true,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '다운로드',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await DeckService().generateDeckRecipePDF(widget.deck);
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

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double iconSize = constraints.maxHeight*0.6;
          return Column(
            children: [

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
                            width: iconSize, height: iconSize),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showDeckCopyDialog(context),
                          iconSize: iconSize,
                          icon: const Icon(Icons.copy),
                          tooltip: '복사해서 새로운 덱 만들기',
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(
                            width: iconSize, height: iconSize),
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
                            width: iconSize, height: iconSize),
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
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(
                            width: iconSize, height: iconSize),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => showDeckReceiptDialog(context),
                          iconSize: iconSize,
                          icon: const Icon(Icons.receipt_long),
                          tooltip: '대회 제출용 레시피',
                        ),
                      ),

                      if (hasManagerRole) // 권한 체크 조건
                        ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                              width: iconSize, height: iconSize),
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
