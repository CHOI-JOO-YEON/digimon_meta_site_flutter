import 'package:flutter/material.dart';

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
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static bool isSmallHeight(BuildContext context) {
    return MediaQuery.of(context).size.height < 600;
  }
  
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
} 