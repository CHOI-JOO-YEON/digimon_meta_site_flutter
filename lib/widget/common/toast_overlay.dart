import 'package:flutter/material.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';

enum ToastType {
  success,
  info,
  warning,
  error,
}

class ToastOverlay {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastType type = ToastType.info,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: SizeService.largePadding(context) * 2.5,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
              padding: SizeService.symmetricPadding(context, horizontal: 4, vertical: 2.4),
              decoration: BoxDecoration(
                color: _getBackgroundColor(type),
                borderRadius: SizeService.customRadius(context, multiplier: 2.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: SizeService.largePadding(context) * 1.6,
                    offset: Offset(0, SizeService.spacingSize(context)),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(type),
                    color: Colors.white,
                    size: SizeService.mediumIconSize(context),
                  ),
                  SizeService.horizontalSpacing(context, multiplier: 2.4),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeService.bodyFontSize(context) * 1.07,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    Future.delayed(duration, () {
      overlay.remove();
    });
  }

  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.info:
        return const Color(0xFF2196F3);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.error:
        return const Color(0xFFF44336);
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.info:
        return Icons.info_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.error:
        return Icons.error_outline;
    }
  }
} 