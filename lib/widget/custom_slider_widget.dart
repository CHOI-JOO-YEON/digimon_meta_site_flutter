import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final int sliderValue;
  final Function(int) sliderAction;
  const CustomSlider({super.key, required this.sliderValue, required this.sliderAction});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _currentSliderValue = 10;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._currentSliderValue = widget.sliderValue as double;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      min: 4,
      max: 20,
      divisions: 16,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
        });
        widget.sliderAction(value.round());
      },
    );
  }
}
