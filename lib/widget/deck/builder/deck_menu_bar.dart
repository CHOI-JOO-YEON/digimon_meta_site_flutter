import 'package:digimon_meta_site_flutter/widget/deck/deck_count_widget.dart';
import 'package:digimon_meta_site_flutter/widget/tab_tooltip.dart';
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

  @override
  Widget build(BuildContext context) {
    if (widget.deck.deckName != _lastDeckName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTextController();
      });
    }
    
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    
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
                      flex: 12,
                      child: TextField(
                        style: TextStyle(
                          fontSize: isSmallHeight 
                            ? SizeService.bodyFontSize(context) * 0.8 
                            : SizeService.bodyFontSize(context),
                        ),
                        controller: widget.textEditingController,
                        onChanged: (v) {
                          widget.deck.deckName = v;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isSmallHeight ? 4 : 8,
                            horizontal: isSmallHeight ? 4 : 8,
                          ),
                          isDense: isSmallHeight, // 작은 화면에서 compact 모드
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: widget.deck.isSave
                          ? Container()
                          : TabTooltip(
                              message: '변경 사항이 저장되지 않았습니다.',
                              child: Icon(
                                Icons.warning, 
                                color: Colors.amber,
                                size: isSmallHeight ? 16 : 20, // 작은 화면에서 아이콘 크기 줄임
                              ),
                            )),
                ],
              )),
          Expanded(
              flex: 2,
              child: SizedBox(
                width: constraints.maxWidth,
                child: DeckCount(
                  deck: widget.deck,
                ),
              ))
        ],
      );
    });
  }
}
