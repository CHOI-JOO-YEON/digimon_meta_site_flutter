import 'package:digimon_meta_site_flutter/widget/draggalbe_card.dart';
import 'package:flutter/material.dart';

import '../model/card.dart';

class StackHand extends StatefulWidget {
  final List<DigimonCard> hands;

  const StackHand({super.key, required this.hands});

  @override
  State<StackHand> createState() => _StackHandState();
}

class _StackHandState extends State<StackHand> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<DigimonCard>(
      onAccept: (card) {
        widget.hands.add(card);
      },
      onLeave: (card) {
        widget.hands.remove(card);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.red,
            width: 800,
            height: 200,
            child: Stack(
              children: widget.hands.asMap().entries.map((entry) {
                int index = entry.key; // 현재 요소의 인덱스
                var hand = entry.value; // 현재 요소의 값 (여기서는 hand 객체)

                // DraggableCard에 hand 객체와 인덱스를 전달합니다.
                return Positioned(
                    left: index*100,
                    child: DraggableCard(card: hand));
              }).toList(),
            ));
      },
    );
  }
}
