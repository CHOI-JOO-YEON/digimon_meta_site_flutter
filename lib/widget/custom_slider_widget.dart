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

    _currentSliderValue = widget.sliderValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double thumbRadius = screenWidth / 150; // 예시 계산
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if(isPortrait){
      thumbRadius*=2;
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            SliderTheme(

              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
                overlayShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius*1.1),

              ),
              child:  Slider(
                value: _currentSliderValue,
                min: 4,
                max: 14,
                divisions: 10,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                  widget.sliderAction(value.round());
                },
              ),
            )


          ],
            ),
    );
  }
}
