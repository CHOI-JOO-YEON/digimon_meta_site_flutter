import 'package:flutter/material.dart';

class ColorService{

  Color getColorFromString(String colorString) {
    switch (colorString) {
      case 'RED':
        return Colors.red;
      case 'BLUE':
        return Colors.blue;
      case 'YELLOW':
        return Colors.yellow;
      case 'GREEN':
        return Colors.green;
      case 'BLACK':
        return Colors.black;
      case 'PURPLE':
        return Colors.purple;
      case 'WHITE':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }
}