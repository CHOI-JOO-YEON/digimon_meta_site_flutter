import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SizeService {
  static double titleFontSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 20,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 16),
        const Condition.smallerThan(name: DESKTOP, value: 18),
        const Condition.largerThan(name: DESKTOP, value: 22),
      ],
    ).value;
  }
  static double bodyFontSize(BuildContext context) {
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    
    if (isPortrait) {
      return ResponsiveValue<double>(
        context,
        defaultValue: 14,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 9),
          const Condition.smallerThan(name: DESKTOP, value: 11),
          const Condition.largerThan(name: DESKTOP, value: 14),
        ],
      ).value;
    } else {
      return ResponsiveValue<double>(
        context,
        defaultValue: 16,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 10),
          const Condition.smallerThan(name: DESKTOP, value: 12),
          const Condition.largerThan(name: DESKTOP, value: 16),
        ],
      ).value;
    }
  }

  static double smallFontSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 14,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 8),
        const Condition.smallerThan(name: DESKTOP, value: 10),
        const Condition.largerThan(name: DESKTOP, value: 14),
      ],
    ).value;
  }

  static double smallIconSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 14,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 10),
        const Condition.smallerThan(name: DESKTOP, value: 12),
        const Condition.largerThan(name: DESKTOP, value: 16),
      ],
    ).value;
  }
  static double mediumIconSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 20,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 16),
        const Condition.smallerThan(name: DESKTOP, value: 18),
        const Condition.largerThan(name: DESKTOP, value: 22),
      ],
    ).value;
  }
  static double largeIconSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 40,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 26),
        const Condition.smallerThan(name: DESKTOP, value: 28),
        const Condition.largerThan(name: DESKTOP, value: 32),
      ],
    ).value;
  }

  static double paddingSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 5,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 2.5),
        const Condition.smallerThan(name: DESKTOP, value: 4),
        const Condition.largerThan(name: DESKTOP, value: 7),
      ],
    ).value;
  }
  static double roundRadius(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 5,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 2.5),
        const Condition.smallerThan(name: DESKTOP, value: 4),
        const Condition.largerThan(name: DESKTOP, value: 7),
      ],
    ).value;
  }
  static double thumbRadius(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 10,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 6),
        const Condition.smallerThan(name: DESKTOP, value: 8),
        const Condition.largerThan(name: DESKTOP, value: 12),
      ],
    ).value;
  }

  static double spacingSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 3,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 1),
        const Condition.smallerThan(name: DESKTOP, value: 2),
        const Condition.largerThan(name: DESKTOP, value: 4),
      ],
    ).value;
  }

  static double switchScale(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 0.8,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 0.6),
        const Condition.smallerThan(name: DESKTOP, value: 0.7),
        const Condition.largerThan(name: DESKTOP, value: 1),
      ],
    ).value;
  }

  static double headerHeight(BuildContext context) {
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    
    // 세로모드일 때 더 작은 값 반환
    if (isPortrait) {
      return ResponsiveValue<double>(
        context,
        defaultValue: 110,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 120),
          const Condition.smallerThan(name: DESKTOP, value: 120),
          const Condition.largerThan(name: DESKTOP, value: 100),
        ],
      ).value;
    } else {
      return ResponsiveValue<double>(
        context,
        defaultValue: 100,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 120),
          const Condition.smallerThan(name: DESKTOP, value: 120),
          const Condition.largerThan(name: DESKTOP, value: 80),
        ],
      ).value;
    }
  }

  // EdgeInsets 관련 함수들
  static EdgeInsets allPadding(BuildContext context) {
    return EdgeInsets.all(paddingSize(context));
  }

  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: paddingSize(context));
  }

  static EdgeInsets verticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(vertical: paddingSize(context));
  }

  static EdgeInsets symmetricPadding(BuildContext context, {double? horizontal, double? vertical}) {
    final baseSize = paddingSize(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? baseSize * horizontal : baseSize,
      vertical: vertical != null ? baseSize * vertical : baseSize,
    );
  }

  static EdgeInsets customPadding(BuildContext context, {
    double? left, 
    double? top, 
    double? right, 
    double? bottom
  }) {
    final baseSize = paddingSize(context);
    return EdgeInsets.only(
      left: left != null ? baseSize * left : 0,
      top: top != null ? baseSize * top : 0,
      right: right != null ? baseSize * right : 0,
      bottom: bottom != null ? baseSize * bottom : 0,
    );
  }

  // SizedBox 관련 함수들
  static SizedBox horizontalSpacing(BuildContext context, {double multiplier = 1.0}) {
    return SizedBox(width: spacingSize(context) * multiplier);
  }

  static SizedBox verticalSpacing(BuildContext context, {double multiplier = 1.0}) {
    return SizedBox(height: spacingSize(context) * multiplier);
  }

  // BorderRadius 관련 함수들
  static BorderRadius cardRadius(BuildContext context) {
    return BorderRadius.circular(roundRadius(context));
  }

  static BorderRadius buttonRadius(BuildContext context) {
    return BorderRadius.circular(roundRadius(context) * 0.8);
  }

  static BorderRadius dialogRadius(BuildContext context) {
    return BorderRadius.circular(roundRadius(context) * 2);
  }

  static BorderRadius customRadius(BuildContext context, {double multiplier = 1.0}) {
    return BorderRadius.circular(roundRadius(context) * multiplier);
  }

  // 자주 사용되는 크기 배수들
  static double largePadding(BuildContext context) {
    return paddingSize(context) * 2;
  }

  static double smallPadding(BuildContext context) {
    return paddingSize(context) * 0.5;
  }

  static double largeSpacing(BuildContext context) {
    return spacingSize(context) * 2;
  }

  static double smallSpacing(BuildContext context) {
    return spacingSize(context) * 0.5;
  }
}
