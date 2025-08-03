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
                _buildModernIconButton(
                  context: context,
                  icon: Icons.copy_outlined,
                  filledIcon: Icons.copy,
                  tooltip: '복사해서 새로운 덱 만들기',
                  color: const Color(0xFF3B82F6),
                  onPressed: () => DeckService().copyDeck(context, widget.deck),
                ),
                _buildModernIconButton(
                  context: context,
                  icon: Icons.upload_outlined,
                  filledIcon: Icons.upload,
                  tooltip: '내보내기',
                  color: const Color(0xFF0891B2),
                  onPressed: () => DeckService().showExportDialog(context, widget.deck),
                ),
                _buildModernIconButton(
                  context: context,
                  icon: Icons.image_outlined,
                  filledIcon: Icons.image,
                  tooltip: '이미지 저장',
                  color: const Color(0xFFEC4899),
                  onPressed: () {
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
                    context.router.push(GamePlayGroundRoute(deckBuild: widget.deck));
                  },
                ),
                _buildModernIconButton(
                  context: context,
                  icon: Icons.receipt_long_outlined,
                  filledIcon: Icons.receipt_long,
                  tooltip: '대회 제출용 레시피',
                  color: const Color(0xFF0D9488),
                  onPressed: () => DeckService().downloadDeckReceipt(context, widget.deck),
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
        },
      );
    });
  }
}
