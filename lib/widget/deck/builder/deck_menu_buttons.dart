import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/deck-build.dart';
import '../../../model/deck-view.dart';
import '../../../model/format.dart';
import '../../../provider/user_provider.dart';
import '../../../router.dart';
import '../../../service/card_overlay_service.dart';
import '../../../service/deck_service.dart';
import '../../random_hand_widget.dart';

class DeckMenuButtons extends StatefulWidget {
  final DeckBuild deck;
  final Function() init;
  final Function() newCopy;
  final Function() reload;
  final Function(List<String>) sortDeck;
  final Function(DeckView) import;

  const DeckMenuButtons({
    super.key,
    required this.deck,
    required this.init,
    required this.import,
    required this.newCopy,
    required this.reload,
    required this.sortDeck,
  });

  @override
  State<DeckMenuButtons> createState() => _DeckMenuButtonsState();
}

class _DeckMenuButtonsState extends State<DeckMenuButtons> {
  void _showLoginDialog(BuildContext context) {
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text('로그인이 필요합니다.'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Consumer<UserProvider>(builder:
          (BuildContext context, UserProvider userProvider, Widget? child) {
        bool hasManagerRole = userProvider.hasManagerRole();
        return Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: SizeService.spacingSize(context),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    DeckService().showDeckResetDialog(context, widget.init);
                  },
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.add_box),
                  tooltip: '새로 만들기',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => DeckService()
                      .showDeckClearDialog(context, widget.deck, widget.reload),
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.clear),
                  tooltip: '비우기',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      DeckService().showDeckCopyDialog(context, widget.deck),
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.copy),
                  tooltip: '복사해서 새로운 덱 만들기',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    if (userProvider.isLogin) {
                      Map<int, FormatDto> formats =
                          await DeckService().getFormats(widget.deck);
                      DeckService().showSaveDialog(
                          context, formats, widget.deck, widget.reload);
                    } else {
                      _showLoginDialog(context);
                    }
                  },
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.save),
                  tooltip: '저장',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      DeckService().showImportDialog(context, widget.import),
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.download),
                  tooltip: '가져오기',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      DeckService().showExportDialog(context, widget.deck),
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.upload),
                  tooltip: '내보내기',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    CardOverlayService().removeAllOverlays();
                    context.router.push(DeckImageRoute(deck: widget.deck));
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
            CardOverlayService().removeAllOverlays();
            context.router.push(GamePlayGroundRoute(deckBuild: widget.deck));
            },
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.gamepad),
                  tooltip: '플레이그라운드',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      DeckService().showDeckReceiptDialog(context, widget.deck),
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.receipt_long),
                  tooltip: '대회 제출용 레시피',
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: SizeService.largeIconSize(context),
                    height: SizeService.largeIconSize(context)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => DeckService().showDeckSettingDialog(
                      context, widget.deck, widget.reload),
                  iconSize: SizeService.largeIconSize(context),
                  icon: const Icon(Icons.settings),
                  tooltip: '덱 설정',
                ),
              ),
              if (hasManagerRole)
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: SizeService.largeIconSize(context),
                      height: SizeService.largeIconSize(context)),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await DeckService().exportToTTSFile(widget.deck);
                    },
                    iconSize: SizeService.largeIconSize(context),
                    icon: const Icon(Icons.videogame_asset_outlined),
                    tooltip: 'TTS 파일 내보내기',
                  ),
                ),
            ],
          ),
        );
      });
    });
  }
}
