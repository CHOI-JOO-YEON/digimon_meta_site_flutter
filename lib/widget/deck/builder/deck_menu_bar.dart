import 'package:digimon_meta_site_flutter/widget/deck/deck_count_widget.dart';
import 'package:digimon_meta_site_flutter/widget/tab_tooltip.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:flutter/material.dart';

import '../../../model/deck-build.dart';
import '../../../service/size_service.dart';

class DeckBuilderMenuBar extends StatefulWidget {
  final DeckBuild deck;
  final TextEditingController textEditingController;

  const DeckBuilderMenuBar({
    super.key,
    required this.deck,
    required this.textEditingController,
  });

  @override
  State<DeckBuilderMenuBar> createState() => _DeckBuilderMenuBarState();
}

class _DeckBuilderMenuBarState extends State<DeckBuilderMenuBar> {
  final GlobalKey<State<Tooltip>> tooltipKey = GlobalKey<State<Tooltip>>();
  String? _lastDeckName;

  @override
  void didUpdateWidget(covariant DeckBuilderMenuBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deck != oldWidget.deck || widget.deck.deckName != _lastDeckName) {
      _updateTextController();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTextController();
  }

  void _updateTextController() {
    final newDeckName = widget.deck.deckName ?? 'My Deck';
    if (widget.textEditingController.text != newDeckName) {
      widget.textEditingController.text = newDeckName;
    }
    _lastDeckName = widget.deck.deckName;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showUnsavedWarning(BuildContext context) {
    ToastOverlay.show(
      context, 
      '덱에 저장되지 않은 변경사항이 있습니다.', 
      type: ToastType.warning
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deck.deckName != _lastDeckName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTextController();
      });
    }
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    final isMobile = screenWidth < 768; // 모바일 화면 감지
    final isVerySmall = screenWidth < 480; // 매우 작은 화면 감지
    
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: [
          Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                        height: isMobile ? 40 : (isSmallHeight ? 44 : 48), // 명시적 높이 설정
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              const Color(0xFFFAFBFC),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: isMobile ? 6 : 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                            width: isMobile ? 0.5 : 1,
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(
                            fontSize: isMobile 
                              ? SizeService.bodyFontSize(context) * 0.8 
                              : (isSmallHeight 
                                  ? SizeService.bodyFontSize(context) * 0.85 
                                  : SizeService.bodyFontSize(context) * 0.95),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          controller: widget.textEditingController,
                          onChanged: (v) {
                            widget.deck.deckName = v;
                          },
                                                      textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isMobile ? 6 : (isSmallHeight ? 8 : 12),
                                horizontal: isMobile ? 8 : (isSmallHeight ? 12 : 16),
                              ),
                              border: InputBorder.none,
                              hintText: isMobile ? '덱 이름' : '덱 이름을 입력하세요', // 모바일에서 짧은 힌트
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.normal,
                                fontSize: isMobile 
                                  ? SizeService.bodyFontSize(context) * 0.75
                                  : null,
                              ),
                              prefixIcon: Icon(
                                Icons.edit_outlined,
                                size: isMobile ? 14 : 16,
                                color: Colors.grey[500],
                              ),
                            ),
                        ),
                      )),
                  widget.deck.isSave
                      ? Container()
                      : GestureDetector(
                          onTap: () => _showUnsavedWarning(context),
                          child: Container(
                            width: isMobile ? 40 : (isSmallHeight ? 44 : 48), // 정사각형을 위한 width
                            height: isMobile ? 40 : (isSmallHeight ? 44 : 48), // 정사각형을 위한 height
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              color: Colors.amber[600],
                              size: isMobile ? 20 : (isSmallHeight ? 22 : 24),
                            ),
                          ),
                        ),
                ],
              )),
          Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                alignment: Alignment.topLeft,
                child: DeckCount(
                  deck: widget.deck,
                ),
              ),
            )
        ],
      );
    });
  }
}
