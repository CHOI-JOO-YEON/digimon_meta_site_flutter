import 'dart:ui';

class DeckImageColor {
  Color backGroundColor;
  Color textColor;
  Color cardColor;
  Color barColor;
  String name;

  DeckImageColor({this.backGroundColor = const Color(0xffE9E9E9),
    this.textColor = const Color(0xff000000),
    this.cardColor = const Color(0xffffffff),
    this.barColor = const Color(0xff1a237e),
    this.name = "기본"
  });
}
