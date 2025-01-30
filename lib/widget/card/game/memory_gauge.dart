import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/game_state.dart';

class MemoryGauge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Slider(
      value: gameState.memory.toDouble(),
      min: -10,
      max: 10,
      divisions: 20,
      label: gameState.memory.toString(),
      onChanged: (value) {
        gameState.updateMemory(value.toInt());
      },
    );
  }
}
