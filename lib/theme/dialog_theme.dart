import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 다이얼로그 테마와 스타일을 정의
class AppDialogTheme {
  // 색상 정의
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Colors.white;
  static const Color overlayColor = Color(0x80000000);

  // 크기 정의
  static const double borderRadius = 16.0;
  static const double maxDialogWidth = 600.0;
  static const double minDialogWidth = 300.0;
  static const double maxDialogHeight = 700.0;
  static const double contentPadding = 24.0;
  static const double actionsPadding = 16.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;

  // 폰트 크기
  static const double titleFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;

  // 애니메이션
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // 기본 다이얼로그 스타일
  static const ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
  );

  // 그림자 스타일
  static const List<BoxShadow> dialogShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // 버튼 스타일
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(80, 40),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(80, 40),
      );

  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: errorColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(80, 40),
      );

  // 텍스트 스타일
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    height: 1.4,
  );

  static const TextStyle captionTextStyle = TextStyle(
    fontSize: captionFontSize,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  // 반응형 크기 계산
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    
    if (isPortrait) {
      return (screenWidth * 0.9).clamp(minDialogWidth, maxDialogWidth);
    } else {
      return (screenWidth * 0.5).clamp(minDialogWidth, maxDialogWidth);
    }
  }

  static double getDialogHeight(BuildContext context, {double? contentHeight}) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    
    if (contentHeight != null) {
      // 컨텐츠 높이가 주어진 경우, 패딩을 추가하여 계산
      final totalHeight = contentHeight + (contentPadding * 2) + (actionsPadding * 2) + 100; // 여유 공간
      return totalHeight.clamp(0, screenHeight * 0.9);
    }
    
    return (screenHeight * 0.6).clamp(0, maxDialogHeight);
  }

  // 접근성 설정
  static Widget buildAccessibleDialog({
    required BuildContext context,
    required Widget child,
    String? semanticLabel,
    bool barrierDismissible = true,
  }) {
    return Semantics(
      label: semanticLabel ?? '대화 상자',
      child: AlertDialog(
        shape: dialogShape,
        backgroundColor: backgroundColor,
        contentPadding: const EdgeInsets.all(contentPadding),
        actionsPadding: const EdgeInsets.all(actionsPadding),
        content: child,
      ),
    );
  }
}

/// 다이얼로그 유형별 아이콘
class DialogIcons {
  static const IconData success = Icons.check_circle;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData info = Icons.info;
  static const IconData question = Icons.help;
  static const IconData settings = Icons.settings;
  static const IconData save = Icons.save;
  static const IconData delete = Icons.delete;
  static const IconData copy = Icons.copy;
  static const IconData import = Icons.download;
  static const IconData export = Icons.upload;
} 