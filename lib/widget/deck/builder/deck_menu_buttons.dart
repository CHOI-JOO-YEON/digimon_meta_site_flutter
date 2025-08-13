import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/deck-build.dart';
import '../../../model/format.dart';
import '../../../provider/user_provider.dart';
import '../../../router.dart';
import '../../../service/card_overlay_service.dart';
import '../../../service/deck_service.dart';
import '../../common/toast_overlay.dart';

class DeckMenuButtons extends StatefulWidget {
  final DeckBuild deck;
  final Function() init;
  final Function() newCopy;
  final Function() reload;
  final Function(List<String>) sortDeck;
  final Function(DeckBuild) import;

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

  Widget _buildModernIconButton({
    required BuildContext context,
    required IconData icon,
    required IconData filledIcon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: SizeService.largeIconSize(context) + 8,
          height: SizeService.largeIconSize(context) + 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFF8FAFC),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: SizeService.largeIconSize(context) * 0.7,
              color: color,
            ),
          ),
        ),
      ),
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
              _buildModernIconButton(
                context: context,
                icon: Icons.add_box_outlined,
                filledIcon: Icons.add_box,
                tooltip: '새로 만들기',
                color: const Color(0xFF10B981),
                onPressed: () {
                  DeckService().resetDeck(context, () {
                    widget.init();
                    ToastOverlay.show(
                      context,
                      '새로운 덱이 생성되었습니다.',
                      type: ToastType.success
                    );
                  });
                },
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.clear_outlined,
                filledIcon: Icons.clear,
                tooltip: '비우기',
                color: const Color(0xFFEF4444),
                onPressed: () => DeckService()
                    .clearDeck(context, widget.deck, () {
                      widget.reload();
                      ToastOverlay.show(
                        context,
                        '덱이 비워졌습니다.',
                        type: ToastType.warning
                      );
                    }),
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.copy_outlined,
                filledIcon: Icons.copy,
                tooltip: '복사해서 새로운 덱 만들기',
                color: const Color(0xFF3B82F6),
                onPressed: () => DeckService().copyDeck(
                    context,
                    widget.deck,
                    onCopy: widget.newCopy,
                ),
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.save_outlined,
                filledIcon: Icons.save,
                tooltip: '저장',
                color: const Color(0xFF7C3AED),
                onPressed: () async {
                  if (userProvider.isLogin) {
                    Map<int, FormatDto> formats =
                        await DeckService().getFormats(widget.deck);
                    DeckService().showSaveDialog(
                        context, formats, widget.deck, () {
                          widget.reload();
                          ToastOverlay.show(
                            context,
                            '덱이 저장되었습니다.',
                            type: ToastType.success
                          );
                        });
                  } else {
                    _showLoginDialog(context);
                  }
                },
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.download_outlined,
                filledIcon: Icons.download,
                tooltip: '가져오기',
                color: const Color(0xFF059669),
                onPressed: () {
                  DeckService().showImportDialog(context, (deckBuild) {
                    widget.import(deckBuild);
                    ToastOverlay.show(
                      context,
                      '덱을 가져왔습니다.',
                      type: ToastType.success
                    );
                  });
                },
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.upload_outlined,
                filledIcon: Icons.upload,
                tooltip: '내보내기',
                color: const Color(0xFF0891B2),
                onPressed: () =>
                    DeckService().showExportDialog(context, widget.deck),
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.image_outlined,
                filledIcon: Icons.image,
                tooltip: '이미지 저장',
                color: const Color(0xFFDC2626),
                onPressed: () {
                  CardOverlayService().removeAllOverlays();
                  context.router.push(DeckImageRoute(deck: widget.deck));
                },
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.gamepad_outlined,
                filledIcon: Icons.gamepad,
                tooltip: '플레이그라운드',
                color: const Color(0xFF8B5CF6),
                onPressed: () {
                  CardOverlayService().removeAllOverlays();
                  context.router
                      .push(GamePlayGroundRoute(deckBuild: widget.deck));
                },
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.receipt_long_outlined,
                filledIcon: Icons.receipt_long,
                tooltip: '대회 제출용 레시피',
                color: const Color(0xFF0D9488),
                onPressed: () =>
                    DeckService().downloadDeckReceipt(context, widget.deck),
              ),
              _buildModernIconButton(
                context: context,
                icon: Icons.swap_horiz,
                filledIcon: Icons.swap_horiz,
                tooltip: '패럴렐 카드를 일반 카드로 변환',
                color: const Color(0xFFF97316),
                onPressed: () {
                  DeckService().convertParallelToNormal(context, widget.deck, () {
                    widget.reload();
                    ToastOverlay.show(
                      context,
                      '패럴렐 카드가 일반 카드로 변환되었습니다.',
                      type: ToastType.success
                    );
                  });
                },
              ),
              if (hasManagerRole)
                _buildModernIconButton(
                  context: context,
                  icon: Icons.videogame_asset_outlined,
                  filledIcon: Icons.videogame_asset,
                  tooltip: 'TTS 파일 내보내기',
                  color: const Color(0xFF9333EA),
                  onPressed: () async {
                    await DeckService().exportToTTSFile(widget.deck);
                  },
                ),
            ],
          ),
        );
      });
    });
  }
}
