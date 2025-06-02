import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class OrientationService {
  // 기본적인 정보만 제공하는 클래스로 변경
  // 자동회전 강제 제어 기능 제거

  static bool isOrientationLockSupported() {
    if (!kIsWeb) return false;
    try {
      return html.window.screen?.orientation != null;
    } catch (_) {
      return false;
    }
  }

  static String? getCurrentOrientation() {
    if (!kIsWeb) return null;
    try {
      return html.window.screen?.orientation?.type;
    } catch (_) {
      return null;
    }
  }

  static bool isWebApp() {
    if (!kIsWeb) return false;
    try {
      return html.window.matchMedia('(display-mode: standalone)').matches;
    } catch (_) {
      return false;
    }
  }

  static bool isFullscreen() {
    if (!kIsWeb) return false;
    try {
      return html.document.fullscreenElement != null;
    } catch (_) {
      return false;
    }
  }
}
