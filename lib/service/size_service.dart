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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    // 세로모드일 때 더 큰 값 반환
    if (isPortrait) {
      return ResponsiveValue<double>(
        context,
        defaultValue: 140,
        conditionalValues: [
          const Condition.smallerThan(name: TABLET, value: 150),
          const Condition.smallerThan(name: DESKTOP, value: 150),
          const Condition.largerThan(name: DESKTOP, value: 130),
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
}
