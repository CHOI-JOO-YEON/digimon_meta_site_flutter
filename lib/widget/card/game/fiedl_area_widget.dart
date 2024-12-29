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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8, childAspectRatio: 0.35),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          fieldZone: gameState.fieldZones[index],
                          cardWidth: cardWidth,
                          isRaising: false,
                        );
                      },
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 16, childAspectRatio: 0.712),
                      itemCount: gameState.fieldZones.length - 8,
                      itemBuilder: (context, index) {
                        return FieldZoneWidget(
                          fieldZone: gameState.fieldZones[index + 8],
                          cardWidth: cardWidth * 0.5,
                          isRaising: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            ElevatedButton(
              onPressed: () {
                gameState.addFieldZone(16);
              },
              child: const Text('필드 존 추가'),
            ),
          ],
        );
      },
    );
  }
}
