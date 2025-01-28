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

  static double LargeIconSize(BuildContext context) {
    return ResponsiveValue<double>(
      context,
      defaultValue: 24,
      conditionalValues: [
        const Condition.smallerThan(name: TABLET, value: 20),
        const Condition.smallerThan(name: DESKTOP, value: 22),
        const Condition.largerThan(name: DESKTOP, value: 26),
      ],
    ).value;
  }
}
