import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class OrientationService {
  static const String _autoRotateKey = 'allowAutoRotate';

  static bool loadAutoRotate() {
    final stored = html.window.localStorage[_autoRotateKey];
    if (stored == null) return true;
    return stored.toLowerCase() != 'false';
  }

  static void saveAutoRotate(bool value) {
    html.window.localStorage[_autoRotateKey] = value.toString();
  }

  static Future<void> applyAutoRotate(bool value) async {
    try {
      if (value) {
        await html.window.screen?.orientation?.unlock();
      } else {
        await html.window.screen?.orientation?.lock('portrait');
      }
    } catch (_) {}
  }

  static bool isWebApp() {
    if (!kIsWeb) return false;
    try {
      return html.window.matchMedia('(display-mode: standalone)').matches;
    } catch (_) {
      return false;
    }
  }
}
