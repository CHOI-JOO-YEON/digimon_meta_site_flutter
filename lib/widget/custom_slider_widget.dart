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
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.grid_view,
                  size: 16,
                  color: const Color(0xFF2563EB),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2563EB),
                      const Color(0xFF1D4ED8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_currentSliderValue.round()}열',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: SizeService.bodyFontSize(context) * 0.85,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: CustomSliderThumb(
                thumbRadius: SizeService.thumbRadius(context) + 2,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: const Color(0xFF2563EB),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF2563EB).withOpacity(0.1),
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: const Color(0xFF1F2937),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: _currentSliderValue,
              min: 4,
              max: 14,
              divisions: 10,
              label: '${_currentSliderValue.round()}열',
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
                widget.sliderAction(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;

  CustomSliderThumb({required this.thumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // 외부 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(0, 2), thumbRadius, shadowPaint);

    // 메인 썸 (그라데이션)
    final thumbPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          const Color(0xFFF8FAFC),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: thumbRadius));
    canvas.drawCircle(center, thumbRadius, thumbPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, thumbRadius, borderPaint);

    // 내부 아이콘
    final iconPaint = Paint()
      ..color = const Color(0xFF2563EB);
    final iconSize = thumbRadius * 0.6;
    canvas.drawCircle(center, iconSize * 0.3, iconPaint);
  }
}
