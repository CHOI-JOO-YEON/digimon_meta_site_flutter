import 'dart:ui';

class DeckImageColor {
  Color backGroundColor;
  Color textColor;
  Color cardColor;
  Color barColor;
  String name;

  DeckImageColor({
    this.backGroundColor = const Color(0xfff7f8f9),
    this.textColor = const Color(0xff343a40),
    this.cardColor = const Color(0xffffffff),
    this.barColor = const Color(0xFF1976D2),
    this.name = "기본"
  });
}
