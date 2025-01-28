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
      defaultValue: 14,
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
      defaultValue: 12,
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

  static double largeIconSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 30,
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
}
