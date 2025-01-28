import 'package:digimon_meta_site_flutter/service/size_service.dart';
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
  
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            SliderTheme(

              data: SliderTheme.of(context).copyWith(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: SizeService.thumbRadius(context)),
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
