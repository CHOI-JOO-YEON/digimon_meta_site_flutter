import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// 🎨 디지몬 메타 사이트 디자인 시스템
/// 
/// UI/UX 개선 문서에 따른 통합 디자인 시스템
/// 모든 컴포넌트에서 일관된 스타일을 사용하기 위함

/// 🎨 Color Palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);      // 기존 파란색 유지
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  // Secondary Colors  
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF5B21B6);
  
  // Accent Colors
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  
  // Neutral Colors
  static const Color neutral100 = Color(0xFF6B7280);
  static const Color neutral200 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFFE5E7EB);
  static const Color neutral500 = Color(0xFFF3F4F6);
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}

/// 📝 Typography Scale
class AppTypography {
  // Heading styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.3,
  );
}

/// 📏 Spacing System (4px 기본 단위)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
}

/// 🔄 Border Radius System
class AppRadius {
  static const double small = 8.0;   // 버튼, 태그
  static const double medium = 12.0; // 카드, 입력 필드  
  static const double large = 16.0;  // 모달, 컨테이너
  static const double xlarge = 20.0; // 특별한 요소
}

/// 🌟 Shadow System
class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x12000000), // rgba(0,0,0,0.07)
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.1)
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
  ];
}

/// 🎛️ Component Styles
class AppComponentStyles {
  
  /// 통일된 버튼 스타일
  static ButtonStyle primaryButton({
    bool isMobile = false,
    bool isSmall = false,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
      ),
      minimumSize: Size(
        isMobile ? 40 : 44,
        isMobile ? 36 : 44,
      ),
    );
  }
  
  /// 투명한 배경의 primary 버튼 (다른 버튼들과 통일된 스타일)
  static ButtonStyle primaryButtonOutline({
    bool isMobile = false,
    bool isSmall = false,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      foregroundColor: AppColors.primary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
      ),
      minimumSize: Size(
        isMobile ? 40 : 44,
        isMobile ? 36 : 44,
      ),
    );
  }
  
  static ButtonStyle secondaryButton({
    bool isMobile = false,
    bool isSmall = false,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary.withOpacity(0.1),
      foregroundColor: AppColors.secondary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
      ),
      minimumSize: Size(
        isMobile ? 40 : 44,
        isMobile ? 36 : 44,
      ),
    );
  }
  
  static ButtonStyle accentButton({
    bool isMobile = false,
    bool isSmall = false,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent.withOpacity(0.1),
      foregroundColor: AppColors.accent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
      ),
      minimumSize: Size(
        isMobile ? 40 : 44,
        isMobile ? 36 : 44,
      ),
    );
  }
  
  static ButtonStyle warningButton({
    bool isMobile = false,
    bool isSmall = false,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.warning.withOpacity(0.1),
      foregroundColor: AppColors.warning,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: isSmall ? AppSpacing.sm : AppSpacing.md,
      ),
      minimumSize: Size(
        isMobile ? 40 : 44,
        isMobile ? 36 : 44,
      ),
    );
  }
  
  /// 통일된 입력 필드 스타일
  static InputDecoration searchFieldDecoration({
    required String hintText,
    bool isMobile = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textTertiary,
        fontSize: isMobile ? 12 : 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.neutral300,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.neutral300,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2.0,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 16,
        horizontal: isMobile ? 12 : 16,
      ),
    );
  }
  
  /// 통일된 카드 스타일
  static BoxDecoration cardDecoration({
    bool isHovered = false,
  }) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      // boxShadow: isHovered ? AppShadows.medium : AppShadows.small,
      border: Border.all(
        color: AppColors.neutral400,
        width: 0.5,
      ),
    );
  }
}

/// 🎯 Responsive helpers
class AppResponsive {
  // 기존 MediaQuery 기반 함수들
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 768;
  }
  
  static bool isSmallHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 600;
  }
  
  static bool isPortrait(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  // ResponsiveFramework 기반 함수들 (더 정확한 브레이크포인트 사용)
  static bool isMobileDevice(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isMobile;
  }

  static bool isTabletDevice(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isTablet;
  }

  static bool isDesktopDevice(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isDesktop;
  }

  static bool is4K(BuildContext context) {
    return ResponsiveBreakpoints.of(context).largerThan('DESKTOP');
  }

  // 복합 조건 함수들
  static bool isMobilePortrait(BuildContext context) {
    return isMobileDevice(context) && isPortrait(context);
  }

  static bool isTabletPortrait(BuildContext context) {
    return isTabletDevice(context) && isPortrait(context);
  }

  static bool isSmallScreen(BuildContext context) {
    return isMobileDevice(context) || isSmallHeight(context);
  }

  // 그리드 관련 반응형 함수들
  static int getCardGridColumns(BuildContext context) {
    return ResponsiveValue<int>(
      context,
      defaultValue: 6,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 2),
        const Condition.smallerThan(name: DESKTOP, value: 4),
        const Condition.largerThan(name: DESKTOP, value: 8),
      ],
    ).value;
  }

  static int getDeckGridColumns(BuildContext context) {
    final isPortrait = AppResponsive.isPortrait(context);
    if (isPortrait) {
      return ResponsiveValue<int>(
        context,
        defaultValue: 4,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 3),
          const Condition.smallerThan(name: DESKTOP, value: 4),
          const Condition.largerThan(name: DESKTOP, value: 6),
        ],
      ).value;
    } else {
      return ResponsiveValue<int>(
        context,
        defaultValue: 8,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 6),
          const Condition.smallerThan(name: DESKTOP, value: 8),
          const Condition.largerThan(name: DESKTOP, value: 12),
        ],
      ).value;
    }
  }

  // 레이아웃 관련 함수들
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return ResponsiveValue<double>(
      context,
      defaultValue: screenWidth * 0.8,
      conditionalValues: [
        Condition.smallerThan(name: TABLET, value: screenWidth * 0.95),
        Condition.smallerThan(name: DESKTOP, value: screenWidth * 0.7),
        Condition.largerThan(name: DESKTOP, value: screenWidth * 0.6),
      ],
    ).value;
  }

  static double getDialogHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return ResponsiveValue<double>(
      context,
      defaultValue: screenHeight * 0.8,
      conditionalValues: [
        Condition.smallerThan(name: TABLET, value: screenHeight * 0.9),
        Condition.smallerThan(name: DESKTOP, value: screenHeight * 0.8),
        Condition.largerThan(name: DESKTOP, value: screenHeight * 0.7),
      ],
    ).value;
  }

  // 폰트 크기 관련 함수들 (ResponsiveFramework 기반)
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet, 
    required double desktop,
    double? desktop4K,
  }) {
    return ResponsiveValue<double>(
      context,
      defaultValue: tablet,
      conditionalValues: [
        Condition.smallerThan(name: TABLET, value: mobile),
        Condition.smallerThan(name: DESKTOP, value: tablet),
        Condition.largerThan(name: DESKTOP, value: desktop4K ?? desktop),
      ],
    ).value;
  }
} 