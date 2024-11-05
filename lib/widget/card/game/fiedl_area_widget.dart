import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/game_state.dart';
import 'field_zone_widget.dart';

class FieldArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        int crossAxisCount =
            MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3;

        return Column(
          children: [
            Text('필드'),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
                itemCount: gameState.fieldZones.length,
                itemBuilder: (context, index) {
                  return FieldZoneWidget(fieldZone: gameState.fieldZones[index]);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                gameState.fieldZones.add(FieldZone());
                gameState.notifyListeners();
              },
              child: Text('필드 존 추가'),
            ),
          ],
        );
      },
    );
  }
}
