import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../state/game_state.dart';
import 'field_zone_widget.dart';

class FieldArea extends StatelessWidget {
  final double cardWidth;

  const FieldArea({super.key, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Column(
          children: [
            const Text('필드'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 0.35,
                          crossAxisSpacing: cardWidth * 0.05),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          fieldZone: gameState.fieldZones["field$index"]!,
                          cardWidth: cardWidth,
                          isRaising: false,
                        );
                      },
                    ),
                    SizedBox(
                      height: cardWidth * 0.05,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 0.712,
                          crossAxisSpacing: cardWidth * 0.05),
                      itemCount: gameState.fieldZones.length - 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          fieldZone: gameState.fieldZones["field${index + 8}"]!,
                          cardWidth: cardWidth,
                          isRaising: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     gameState.addFieldZone(16);
            //   },
            //   child: const Text('필드 존 추가'),
            // ),
          ],
        );
      },
    );
  }
}
