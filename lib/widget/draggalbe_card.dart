import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/material.dart';

class DraggableCard extends StatelessWidget {
  final DigimonCard card;

  const DraggableCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Draggable<DigimonCard>(
      data: card,
        child: MouseRegion(
          child: Image.network(card.getDisplaySmallImgUrl()??''),
        ),
        feedback: Material(
            child: Text('1',
                style: TextStyle(fontSize: 18, color: Colors.black))));
  }
}
