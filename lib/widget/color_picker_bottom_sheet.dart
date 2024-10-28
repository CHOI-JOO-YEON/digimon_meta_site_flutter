import 'dart:math';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../service/deck_image_color_service.dart';

class ColorPickerBottomSheet extends StatefulWidget {
  final Function(Color) onColorChanged;
  final double scaleFactor;

  const ColorPickerBottomSheet(
      {super.key, required this.onColorChanged, required this.scaleFactor});

  @override
  State<ColorPickerBottomSheet> createState() => _ColorPickerBottomSheetState();
}

class _ColorPickerBottomSheetState extends State<ColorPickerBottomSheet> {
  Color pickerColor = Colors.blue;
  String selectedColorType = 'background';

  @override
  void initState() {
    super.initState();
    pickerColor =
        DeckImageColorService().selectedDeckImageColor.backGroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColorButton(
              label: "배경",
              color: DeckImageColorService()
                  .selectedDeckImageColor
                  .backGroundColor,
              onTap: () {
                setState(() {
                  selectedColorType = 'background';
                  pickerColor = DeckImageColorService()
                      .selectedDeckImageColor
                      .backGroundColor;
                });
              },
            ),
            _buildColorButton(
              label: "텍스트",
              color: DeckImageColorService().selectedDeckImageColor.textColor,
              onTap: () {
                setState(() {
                  selectedColorType = 'text';
                  pickerColor =
                      DeckImageColorService().selectedDeckImageColor.textColor;
                });
              },
            ),
            _buildColorButton(
              label: "카드",
              color: DeckImageColorService().selectedDeckImageColor.cardColor,
              onTap: () {
                setState(() {
                  selectedColorType = 'card';
                  pickerColor =
                      DeckImageColorService().selectedDeckImageColor.cardColor;
                });
              },
            ),
            _buildColorButton(
              label: "스탯바",
              color: DeckImageColorService().selectedDeckImageColor.barColor,
              onTap: () {
                setState(() {
                  selectedColorType = 'bar';
                  pickerColor =
                      DeckImageColorService().selectedDeckImageColor.barColor;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ColorPicker(
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.primary: true,
                ColorPickerType.accent: true,
                                    ColorPickerType.wheel: true,

              },
              pickerTypeLabels: const<ColorPickerType,String>{
                ColorPickerType.primary: "기본색",
                ColorPickerType.accent: "강조색",
                ColorPickerType.wheel: "색상 휠",

              },

              color: pickerColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickerColor = color;
                });
                _applyColorChange(color); // 즉시 변경 적용
              },
            ),
          ),
        ),
      ],
    );
  }

  // 색상 버튼을 생성하는 위젯
  Widget _buildColorButton(
      {required String label, required Color color, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        children: [
          Container(
            width: 40 * widget.scaleFactor,
            height: 40 * widget.scaleFactor,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
          ),
          SizedBox(height: 8 * widget.scaleFactor),
          Text(label),
        ],
      ),
    );
  }

  // 선택된 색상을 업데이트하는 함수
  void _applyColorChange(Color color) {
    switch (selectedColorType) {
      case 'background':
        DeckImageColorService().updateBackGroundColor(color);
        break;
      case 'text':
        DeckImageColorService().updateTextColor(color);
        break;
      case 'card':
        DeckImageColorService().updateCardColor(color);
        break;
      case 'bar':
        DeckImageColorService().updateBarColor(color);
        break;
    }

    widget.onColorChanged(color); // 상위 위젯의 상태 변경 호출
  }
}
