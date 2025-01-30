import 'dart:math';

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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(widget.deckBuild),
      child: Scaffold(
          appBar: AppBar(
            title: Text('플레이 그라운드'),
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
            return Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () => gameState.undo(),
                              icon: Icon(Icons.undo)),
                          IconButton(
                              onPressed: () => gameState.redo(),
                              icon: Icon(Icons.redo)),
                          IconButton(
                              onPressed: () => gameState.init(widget.deckBuild),
                              icon: Icon(Icons.refresh)),
                        ],
                      ),
                      gameState.getSelectedCard() == null
                          ? Container()
                          : Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: gameState
                                            .getSelectedCard()!
                                            .localeCardData
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          LocaleCardData localeCardData =
                                              entry.value;
                                          return TextButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedLocaleIndex = index;
                                              });
                                            },
                                            child: Text(
                                              localeCardData.locale,
                                              style: TextStyle(
                                                fontSize: fontSize * 0.8,
                                                color:
                                                    selectedLocaleIndex == index
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.grey,
                                                fontWeight:
                                                    selectedLocaleIndex == index
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      // SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            localeCardData?.name ?? '데이터 없음',
                                            style: TextStyle(
                                              fontSize: fontSize * 1.2,
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
                                                    width: constraints.maxWidth,
                                                    child: Stack(
                                                      children: [
                                                        SizedBox(
                                                          width: constraints
                                                              .maxWidth,
                                                          child: Image.network(
                                                            gameState
                                                                    .getSelectedCard()!
                                                                    .getDisplayImgUrl() ??
                                                                '',
                                                            fit:
                                                                BoxFit.fitWidth,
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
                                      // const SizedBox(height: 5),
                                      // 텍스트 간소화 스위치
                                      Consumer<TextSimplifyProvider>(
                                        builder: (context, textSimplifyProvider,
                                            child) {
                                          return Row(
                                            children: [
                                              Text('텍스트 간소화'),
                                              Switch(
                                                value: textSimplifyProvider
                                                    .getTextSimplify(),
                                                onChanged: (v) {
                                                  textSimplifyProvider
                                                      .updateTextSimplify(v);
                                                },
                                                inactiveThumbColor: Colors.red,
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                      // const SizedBox(height: 5),
                                      // _effectWidget에 isTextSimplify 전달
                                      Consumer<TextSimplifyProvider>(
                                        builder: (context, textSimplifyProvider,
                                            child) {
                                          return Column(
                                            children: [
                                              if (localeCardData.effect != null)
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
                                                  textSimplifyProvider
                                                      .getTextSimplify(),
                                                ),
                                              const SizedBox(height: 5),
                                              if (localeCardData.sourceEffect !=
                                                  null)
                                                CardService().effectWidget(
                                                  context,
                                                  localeCardData.sourceEffect!,
                                                  '하단 텍스트',
                                                  ColorService
                                                      .getColorFromString(
                                                          gameState
                                                              .getSelectedCard()!
                                                              .color1!),
                                                  fontSize,
                                                  localeCardData.locale,
                                                  textSimplifyProvider
                                                      .getTextSimplify(),
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
                Container(
                  color: Theme.of(context).cardColor,
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(flex: 1, child: MemoryGauge()),
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
                                            cardWidth: cardWidth * 0.85,
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
            );
          })),
    );
  }
}
