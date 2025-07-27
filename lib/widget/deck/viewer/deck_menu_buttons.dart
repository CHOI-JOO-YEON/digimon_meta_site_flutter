import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/deck-build.dart';
import '../../../provider/user_provider.dart';
import '../../../router.dart';
import '../../../service/deck_service.dart';
import '../../../service/size_service.dart';

class DeckMenuButtons extends StatefulWidget {
  final DeckBuild deck;

  const DeckMenuButtons({super.key, required this.deck});

  @override
  State<DeckMenuButtons> createState() => _DeckMenuButtonsState();
}

class _DeckMenuButtonsState extends State<DeckMenuButtons> {
  

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Consumer<UserProvider>(
        builder: (BuildContext context, UserProvider userProvider,
            Widget? child) {
          bool hasManagerRole = userProvider.hasManagerRole(); // 권한 확인
          return Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: SizeService.spacingSize(context),
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: SizeService.largeIconSize(context), height: SizeService.largeIconSize(context)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => DeckService().copyDeck(context, widget.deck),
                    iconSize: SizeService.largeIconSize(context),
                    icon: const Icon(Icons.copy),
                    tooltip: '복사해서 새로운 덱 만들기',
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: SizeService.largeIconSize(context), height: SizeService.largeIconSize(context)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => DeckService().showExportDialog(context,widget.deck),
                    iconSize: SizeService.largeIconSize(context),
                    icon: const Icon(Icons.upload),
                    tooltip: '내보내기',
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: SizeService.largeIconSize(context), height: SizeService.largeIconSize(context)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.router
                          .push(DeckImageRoute(deck: widget.deck));
                    },
                    iconSize: SizeService.largeIconSize(context),
                    icon: const Icon(Icons.image),
                    tooltip: '이미지 저장',
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: SizeService.largeIconSize(context),
                      height: SizeService.largeIconSize(context)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context.router
                          .push(GamePlayGroundRoute(deckBuild: widget.deck));
                    },
                    iconSize: SizeService.largeIconSize(context),
                    icon: const Icon(Icons.gamepad),
                    tooltip: '플레이그라운드',
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: SizeService.largeIconSize(context), height: SizeService.largeIconSize(context)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => DeckService().downloadDeckReceipt(context, widget.deck),
                    iconSize: SizeService.largeIconSize(context),
                    icon: const Icon(Icons.receipt_long),
                    tooltip: '대회 제출용 레시피',
                  ),
                ),
                if (hasManagerRole)
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: SizeService.largeIconSize(context), height: SizeService.largeIconSize(context)),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await DeckService()
                            .exportToTTSFile(widget.deck);
                      },
                      iconSize: SizeService.largeIconSize(context),
                      icon: const Icon(Icons.videogame_asset_outlined),
                      tooltip: 'TTS 파일 내보내기',
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }
}
