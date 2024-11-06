import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/card.dart';

class CardWidget extends StatelessWidget {
  final DigimonCard card;

  CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 90,
      child: Image.network(
        card.imgUrl ?? '',
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey,
            child: Center(child: Text(card.cardName ?? 'Unknown')),
          );
        },
      ),
    );
  }
}
