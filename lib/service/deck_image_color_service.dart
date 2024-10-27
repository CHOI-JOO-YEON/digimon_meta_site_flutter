import 'dart:ui';

import '../model/deck_image_color.dart';

class DeckImageColorService {
  DeckImageColor selectedDeckImageColor = DeckImageColor();
  Map<String, List<DeckImageColor>> selectableColorMap = {};

  static final DeckImageColorService _instance =
      DeckImageColorService._internal();

  static bool _isInitialized = false;

  factory DeckImageColorService() {
    if (!_isInitialized) {
      _instance._initializeColors();
      _isInitialized = true;
    }
    return _instance;
  }

  DeckImageColorService._internal();

  void updateBackGroundColor(Color color) {
    selectedDeckImageColor.backGroundColor = color;
  }

  void updateTextColor(Color color) {
    selectedDeckImageColor.textColor = color;
  }

  void updateCardColor(Color color) {
    selectedDeckImageColor.cardColor = color;
  }

  void updateBarColor(Color color) {
    selectedDeckImageColor.barColor = color;
  }

  void updateColor(DeckImageColor deckImageColor) {
    updateBackGroundColor(deckImageColor.backGroundColor);
    updateCardColor(deckImageColor.cardColor);
    updateTextColor(deckImageColor.textColor);
    updateBarColor(deckImageColor.barColor);
  }

  void _initializeColors() {
    insertRedColors(selectableColorMap);
    insertBlueColors(selectableColorMap);
    insertYellowColors(selectableColorMap);
    insertGreenColors(selectableColorMap);
    insertBlackColors(selectableColorMap);
    insertPurpleColors(selectableColorMap);
  }

  static void insertRedColors(
      Map<String, List<DeckImageColor>> selectableColorMap) {
    List<DeckImageColor> imageColors = [];

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffC84B4B),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff9B1D1D),
        barColor: const Color(0xffE68A8A),
        name: "따스한 붉은빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffF7D2D2),
        textColor: const Color(0xff7B1A1A),
        cardColor: const Color(0xffE39A9A),
        barColor: const Color(0xffD94D4D),
        name: "부드러운 분홍빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffD9594C),
        textColor: const Color(0xffFFD479),
        cardColor: const Color(0xff8A2B2B),
        barColor: const Color(0xffE6B13E),
        name: "붉은 태양"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffB84A3B),
        textColor: const Color(0xff4D87D4),
        cardColor: const Color(0xff873634),
        barColor: const Color(0xff72A1D1),
        name: "푸른 불꽃"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffD9746C),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xffA04945),
        barColor: const Color(0xff86D1A0),
        name: "초록빛 열정"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffB84A3B),
        textColor: const Color(0xff1C1C1C),
        cardColor: const Color(0xff873634),
        barColor: const Color(0xffE68A8A),
        name: "어두운 심장"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffD95151),
        textColor: const Color(0xff9B57D3),
        cardColor: const Color(0xff873634),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 열정"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffDA6B5B),
        textColor: const Color(0xffFFD479),
        cardColor: const Color(0xff8A2B2B),
        barColor: const Color(0xffFF9E80),
        name: "타오르는 열정"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffE66D6D),
        textColor: const Color(0xffF5F5F5),
        cardColor: const Color(0xffA04945),
        barColor: const Color(0xffF4978E),
        name: "따스한 붉은빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffC95149),
        textColor: const Color(0xffFFE799),
        cardColor: const Color(0xff8A2B2B),
        barColor: const Color(0xffFF6F61),
        name: "붉은 대지"));

    selectableColorMap["RED"] = imageColors;
  }

  static void insertBlueColors(
      Map<String, List<DeckImageColor>> selectableColorMap) {
    List<DeckImageColor> imageColors = [];

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff4B79A1),
        textColor: const Color(0xffF5F5F5),
        cardColor: const Color(0xff2F4E70),
        barColor: const Color(0xffA6C7E1),
        name: "푸른 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffB3D1E6),
        textColor: const Color(0xff4A4E69),
        cardColor: const Color(0xffA1BEE9),
        barColor: const Color(0xff7F95D1),
        name: "부드러운 하늘"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff4D8FAD),
        textColor: const Color(0xffFFD479),
        cardColor: const Color(0xff2F6F90),
        barColor: const Color(0xffE6B13E),
        name: "푸른 바다와 태양"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff4B79A1),
        textColor: const Color(0xffD85555),
        cardColor: const Color(0xff2F4E70),
        barColor: const Color(0xffC37C7C),
        name: "붉은 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff4B9BB7),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xff2F4E70),
        barColor: const Color(0xffA1E8AF),
        name: "초록빛 바다"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff4D8FAD),
        textColor: const Color(0xff9B57D3),
        cardColor: const Color(0xff2F6F90),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 물결"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff354F6A),
        textColor: const Color(0xff1C1C1C),
        cardColor: const Color(0xff2F4E70),
        barColor: const Color(0xffA6C7E1),
        name: "어두운 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff4B79A1),
        textColor: const Color(0xffF5F5F5),
        cardColor: const Color(0xff5A7F94),
        barColor: const Color(0xff7EC8E3),
        name: "차가운 하늘"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff5A7F94),
        textColor: const Color(0xffFFD479),
        cardColor: const Color(0xff4B79A1),
        barColor: const Color(0xffC7E9B0),
        name: "푸른 황혼"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffA1BEE9),
        textColor: const Color(0xff4D5A6C),
        cardColor: const Color(0xff4B79A1),
        barColor: const Color(0xffF5F5F5),
        name: "맑은 바람"));

    selectableColorMap["BLUE"] = imageColors;
  }

  static void insertYellowColors(
      Map<String, List<DeckImageColor>> selectableColorMap) {
    List<DeckImageColor> imageColors = [];

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffE6B13E),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xffB69230),
        barColor: const Color(0xffFFE799),
        name: "따뜻한 황금빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffFFF7D6),
        textColor: const Color(0xff997E30),
        cardColor: const Color(0xffFFD699),
        barColor: const Color(0xffE6B13E),
        name: "부드러운 햇살"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffF2C44D),
        textColor: const Color(0xffD36B5C),
        cardColor: const Color(0xffE6B13E),
        barColor: const Color(0xffC3705A),
        name: "노란 불꽃"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffF2D060),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xffE6B13E),
        barColor: const Color(0xffA1E8AF),
        name: "푸른 들판"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffF0C64D),
        textColor: const Color(0xff4D87D4),
        cardColor: const Color(0xffE6B13E),
        barColor: const Color(0xff72A1D1),
        name: "푸른 하늘"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffF2C44D),
        textColor: const Color(0xff9B57D3),
        cardColor: const Color(0xffE6B13E),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 황금"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffE6B13E),
        textColor: const Color(0xff1C1C1C),
        cardColor: const Color(0xffB69230),
        barColor: const Color(0xffFFE799),
        name: "검은 태양"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffF2D060),
        textColor: const Color(0xff997E30),
        cardColor: const Color(0xffFFE799),
        barColor: const Color(0xffE6B13E),
        name: "따뜻한 빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffFFE799),
        textColor: const Color(0xffE6B13E),
        cardColor: const Color(0xffB69230),
        barColor: const Color(0xffFFD699),
        name: "노란 꿈"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffE6B13E),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xffFFE799),
        barColor: const Color(0xffFFD699),
        name: "황금빛 바람"));

    selectableColorMap["YELLOW"] = imageColors;
  }

  static void insertGreenColors(
      Map<String, List<DeckImageColor>> selectableColorMap) {
    List<DeckImageColor> imageColors = [];

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff5AA468),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff397942),
        barColor: const Color(0xffA1E8AF),
        name: "초록빛 숲"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffC7E9B0),
        textColor: const Color(0xff3A5935),
        cardColor: const Color(0xffA1E8AF),
        barColor: const Color(0xff7FC590),
        name: "부드러운 초록빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff5AA468),
        textColor: const Color(0xffE6B13E),
        cardColor: const Color(0xff397942),
        barColor: const Color(0xffFFE799),
        name: "초록빛 들판"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff7FC590),
        textColor: const Color(0xffD36B5C),
        cardColor: const Color(0xff5AA468),
        barColor: const Color(0xffC3705A),
        name: "붉은 초원"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff5AA468),
        textColor: const Color(0xff4D87D4),
        cardColor: const Color(0xff397942),
        barColor: const Color(0xff72A1D1),
        name: "푸른 숲"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff7FC590),
        textColor: const Color(0xff9B57D3),
        cardColor: const Color(0xff5AA468),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 숲"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff397942),
        textColor: const Color(0xff1C1C1C),
        cardColor: const Color(0xff5AA468),
        barColor: const Color(0xffA1E8AF),
        name: "어두운 숲"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff5AA468),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff397942),
        barColor: const Color(0xffC7E9B0),
        name: "싱그러운 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffC7E9B0),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xff397942),
        barColor: const Color(0xffA1E8AF),
        name: "초록빛 꿈"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff5AA468),
        textColor: const Color(0xffE6B13E),
        cardColor: const Color(0xffC7E9B0),
        barColor: const Color(0xffA1E8AF),
        name: "초록빛 바람"));

    selectableColorMap["GREEN"] = imageColors;
  }

  static void insertBlackColors(
      Map<String, List<DeckImageColor>> selectableColorMap) {
    List<DeckImageColor> imageColors = [];

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xffA6A6A6),
        name: "어두운 심연"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffD1D1D1),
        textColor: const Color(0xff1F1F1F),
        cardColor: const Color(0xffA6A6A6),
        barColor: const Color(0xff808080),
        name: "부드러운 회색"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xffD36B5C),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xffC3705A),
        name: "붉은 심연"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xffE6B13E),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xffFFE799),
        name: "검은 태양"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xffA1E8AF),
        name: "검은 숲"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xff4D87D4),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xff72A1D1),
        name: "검은 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xff9B57D3),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 어둠"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xff808080),
        name: "검은 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff1F1F1F),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff2B2B2B),
        barColor: const Color(0xffA6A6A6),
        name: "검은 대지"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff2B2B2B),
        textColor: const Color(0xffD36B5C),
        cardColor: const Color(0xff1F1F1F),
        barColor: const Color(0xffC3705A),
        name: "검은 열정"));

    selectableColorMap["BLACK"] = imageColors;
  }

  static void insertPurpleColors(
      Map<String, List<DeckImageColor>> selectableColorMap) {
    List<DeckImageColor> imageColors = [];

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 바람"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffD6C6E9),
        textColor: const Color(0xff6A3491),
        cardColor: const Color(0xffC7A1D9),
        barColor: const Color(0xffA57EBF),
        name: "부드러운 라일락"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xffD36B5C),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xffC3705A),
        name: "보랏빛 불꽃"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xffE6B13E),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xffFFE799),
        name: "보랏빛 태양"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xff5AA468),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xffA1E8AF),
        name: "보랏빛 들판"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xff4D87D4),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xff72A1D1),
        name: "푸른 보랏빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff6A3491),
        textColor: const Color(0xff1C1C1C),
        cardColor: const Color(0xff9B57D3),
        barColor: const Color(0xffC7A1D9),
        name: "어두운 보랏빛"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xffFFFFFF),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xffC7A1D9),
        name: "보랏빛 꿈"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xffC7A1D9),
        textColor: const Color(0xff6A3491),
        cardColor: const Color(0xff9B57D3),
        barColor: const Color(0xffD6C6E9),
        name: "보랏빛 신비"));

    imageColors.add(DeckImageColor(
        backGroundColor: const Color(0xff9B57D3),
        textColor: const Color(0xffE6B13E),
        cardColor: const Color(0xff6A3491),
        barColor: const Color(0xffFFE799),
        name: "황금빛 보랏빛"));

    selectableColorMap["PURPLE"] = imageColors;
  }
}
