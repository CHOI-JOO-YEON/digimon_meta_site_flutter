import 'package:flutter/material.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';

/// 실물 TCG 카드 감성: borderRadius ≈ width * 0.05
class CardImageFallback extends StatelessWidget {
  final DigimonCard card;

  /// 외부에서 특정 크기를 주고 싶으면 사용 (없으면 부모 제약 채움)
  final double? width;
  final double? height;

  /// width 대비 보더레디우스 비율 (기본 5% ≒ 3.2mm @ 63mm)
  final double borderRadiusRatio;

  /// 가로세로 비율 (옵션). height 미지정 시 width/aspectRatio로 계산
  final double? aspectRatio;

  const CardImageFallback({
    super.key,
    required this.card,
    this.width,
    this.height,
    this.borderRadiusRatio = 0.05, // 표준 카드 감성
    this.aspectRatio = 0.715,
  });

  @override
  Widget build(BuildContext context) {
    final content = _ScaledContent(
      card: card,
      borderRadiusRatio: borderRadiusRatio,
    );

    if (width != null && height == null && aspectRatio != null) {
      return SizedBox(width: width, height: width! / aspectRatio!, child: content);
    }
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: content);
    }
    return content; // 부모 제약을 꽉 채움
  }
}

class _ScaledContent extends StatelessWidget {
  final DigimonCard card;
  final double borderRadiusRatio;

  const _ScaledContent({
    required this.card,
    required this.borderRadiusRatio,
  });

  @override
  Widget build(BuildContext context) {
    final String displayCardNo = card.cardNo ?? '';
    final String displayCardName = card.getDisplayName() ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final double baseWidth = w < 80 ? 80 : w;

        // 보더 레디우스: width 기준 비율로 자동 계산 (하한/상한 가볍게 클램프)
        final double scaledRadius = (w * borderRadiusRatio).clamp(2.0, 24.0);

        // 테두리 두께도 비율 기반으로 (가벼운 클램프)
        final double scaledBorder = (w * 0.003).clamp(0.75, 2.0);

        return SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
              ),
              borderRadius: BorderRadius.circular(scaledRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: scaledBorder,
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(baseWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: baseWidth * 0.2,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(height: baseWidth * 0.04),
                    Text(
                      displayCardNo,
                      style: TextStyle(
                        fontSize: baseWidth * 0.14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'JalnanGothic',
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (displayCardName.isNotEmpty) ...[
                      SizedBox(height: baseWidth * 0.02),
                      Text(
                        displayCardName,
                        style: TextStyle(
                          fontSize: baseWidth * 0.1,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'JalnanGothic',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
