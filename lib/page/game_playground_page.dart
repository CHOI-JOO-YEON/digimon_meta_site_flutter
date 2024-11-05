import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';

import 'package:auto_route/auto_route.dart';
import '../model/deck-build.dart';
import '../state/game_state.dart';
import '../widget/card/game/deck_area.dart';
import '../widget/card/game/fiedl_area_widget.dart';
import '../widget/card/game/hand_area.dart';
import '../widget/card/game/memory_gauge.dart';
import '../widget/card/game/razing_zone_widget.dart';
import '../widget/card/game/security_stack_area.dart';
import '../widget/card/game/trash_area.dart';

@RoutePage()
class GamePlaygroundPage extends StatelessWidget {
  final DeckBuild deckBuild;

  GamePlaygroundPage({required this.deckBuild});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(deckBuild),
      child: Scaffold(
          appBar: AppBar(
            title: Text('플레이 그라운드'),
          ),
          body: Column(
            children: [
              MemoryGauge(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          SecurityStackArea(),
                          // RaisingZoneWidget(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(flex: 3, child: FieldArea()),
                          Expanded(flex: 1, child: HandArea()),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(flex: 1, child: DeckArea()),
                          Expanded(flex: 1, child: TrashArea()),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
