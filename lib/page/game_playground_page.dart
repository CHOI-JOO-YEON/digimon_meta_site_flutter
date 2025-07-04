import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import '../model/deck-build.dart';
import '../model/locale_card_data.dart';
import '../provider/text_simplify_provider.dart';
import '../service/color_service.dart';
import '../state/game_state.dart';
import '../widget/card/game/deck_area.dart';
import '../widget/card/game/field_area_widget.dart';
import '../widget/card/game/hand_area.dart';
import '../widget/card/game/memory_gauge.dart';
import '../widget/card/game/razing_zone_widget.dart';
import '../widget/card/game/security_stack_area.dart';
import '../widget/card/game/show_cards_widget.dart';
import '../widget/card/game/trash_area.dart';

@RoutePage()
class GamePlayGroundPage extends StatefulWidget {
  final DeckBuild deckBuild;

  const GamePlayGroundPage({super.key, required this.deckBuild});

  @override
  State<GamePlayGroundPage> createState() => _GamePlayGroundPageState();
}

class _GamePlayGroundPageState extends State<GamePlayGroundPage> {
  void _showResetConfirmDialog(BuildContext context, GameState gameState) {
    // 게임이 진행되지 않은 상태(undo가 불가능한 상태)라면 바로 초기화
    if (gameState.undoStack.isEmpty && gameState.redoStack.isEmpty) {
      gameState.init(widget.deckBuild);
      return;
    }
    
    // 게임이 진행된 상태라면 컨펌 창 띄우기
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('초기화 확인'),
          content: const Text('정말로 게임을 초기화하시겠습니까?\n모든 진행 상황이 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameState.init(widget.deckBuild);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(widget.deckBuild),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('플레이그라운드'),
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double width = constraints.maxWidth * 0.8;
            double height = width * (3.5 / 6);
            double cardWidth = width / 12;
            final gameState = Provider.of<GameState>(context);
            double fontSize = width * 0.01;
            int selectedLocaleIndex = 0;
            LocaleCardData? localeCardData = gameState
                .getSelectedCard()
                ?.localeCardData[selectedLocaleIndex];
            return Container(
              color: Theme.of(context).cardColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(width * 0.01),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                // color: Colors.grey[100],
                                // borderRadius: BorderRadius.circular(5)
                                ),
                            child: Row(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: gameState.iconWidth(cardWidth),
                                      height: gameState.iconWidth(cardWidth)),
                                  child: IconButton(
                                    onPressed: () => gameState.undo(),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.undo,
                                      size: gameState.iconWidth(cardWidth),
                                      color: gameState.undoStack.isEmpty
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                    tooltip: '뒤로',
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: gameState.iconWidth(cardWidth),
                                      height: gameState.iconWidth(cardWidth)),
                                  child: IconButton(
                                    onPressed: () => gameState.redo(),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.redo,
                                      size: gameState.iconWidth(cardWidth),
                                      color: gameState.redoStack.isEmpty
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                    tooltip: '앞으로',
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: gameState.iconWidth(cardWidth),
                                      height: gameState.iconWidth(cardWidth)),
                                  child: IconButton(
                                    onPressed: () => _showResetConfirmDialog(context, gameState),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.refresh,
                                      size: gameState.iconWidth(cardWidth),
                                    ),
                                    tooltip: '초기화',
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                      width: gameState.iconWidth(cardWidth),
                                      height: gameState.iconWidth(cardWidth)),
                                  child: IconButton(
                                    onPressed: () => gameState.addTokenToHand(),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.token,
                                      size: gameState.iconWidth(cardWidth),
                                    ),
                                    tooltip: '토큰 추가',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          gameState.getSelectedCard() == null
                              ? Container()
                              : Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                localeCardData?.name ??
                                                    '데이터 없음',
                                                style: TextStyle(
                                                  fontSize: fontSize * 1.5,
                                                  fontFamily:
                                                      localeCardData!.locale ==
                                                              'JPN'
                                                          ? "MPLUSC"
                                                          : "JalnanGothic",
                                                ),
                                              ),
                                            ],
                                          ),
                                          // SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 6,
                                                child: Column(
                                                  children: [
                                                    LayoutBuilder(builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                      return SizedBox(
                                                        width: constraints
                                                            .maxWidth,
                                                        child: Stack(
                                                          children: [
                                                            SizedBox(
                                                              width: constraints
                                                                  .maxWidth,
                                                              child:
                                                                  Image.network(
                                                                gameState
                                                                        .getSelectedCard()!
                                                                        .getDisplayImgUrl() ??
                                                                    '',
                                                                fit: BoxFit
                                                                    .fitWidth,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Consumer<TextSimplifyProvider>(
                                            builder: (context,
                                                textSimplifyProvider, child) {
                                              return Column(
                                                children: [
                                                  if (localeCardData.effect !=
                                                      null)
                                                    CardService().effectWidget(
                                                      context,
                                                      localeCardData.effect!,
                                                      '상단 텍스트',
                                                      ColorService
                                                          .getColorFromString(
                                                              gameState
                                                                  .getSelectedCard()!
                                                                  .color1!),
                                                      fontSize,
                                                      localeCardData.locale,
                                                      true,
                                                    ),
                                                  const SizedBox(height: 5),
                                                  if (localeCardData
                                                          .sourceEffect !=
                                                      null)
                                                    CardService().effectWidget(
                                                      context,
                                                      localeCardData
                                                          .sourceEffect!,
                                                      '하단 텍스트',
                                                      ColorService
                                                          .getColorFromString(
                                                              gameState
                                                                  .getSelectedCard()!
                                                                  .color1!),
                                                      fontSize,
                                                      localeCardData.locale,
                                                      true,
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ]),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                                flex: 1,
                                child: MemoryGauge(
                                  cardWidth: cardWidth,
                                )),
                            Expanded(
                              flex: 8,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: SecurityStackArea(
                                              cardWidth: cardWidth,
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: RaisingZoneWidget(
                                              cardWidth: cardWidth,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: FieldArea(
                                              cardWidth: cardWidth,
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: HandArea(
                                              cardWidth: cardWidth,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: DeckArea(
                                              cardWidth: cardWidth,
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: TrashArea(
                                              cardWidth: cardWidth,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        if (gameState.isShowDialog() || gameState.isShowTrash)
                          Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                  height: cardWidth * 6,
                                  width: cardWidth * 6,
                                  child: ShowCards(
                                    cardWidth: cardWidth,
                                  ))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })),
    );
  }
}
