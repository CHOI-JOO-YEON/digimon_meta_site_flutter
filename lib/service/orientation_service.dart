import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class OrientationService {
  static const String _autoRotateKey = 'allowAutoRotate';
  static const String _deviceSettingFollowKey = 'followDeviceAutoRotate';

  // 기기 설정을 따를지 여부를 로드
  static bool loadFollowDeviceSetting() {
    final stored = html.window.localStorage[_deviceSettingFollowKey];
    if (stored == null) return true; // 기본값: 기기 설정 따르기
    return stored.toLowerCase() != 'false';
  }

  // 기기 설정을 따를지 여부를 저장
  static void saveFollowDeviceSetting(bool value) {
    html.window.localStorage[_deviceSettingFollowKey] = value.toString();
  }

  static bool loadAutoRotate() {
    final stored = html.window.localStorage[_autoRotateKey];
    if (stored == null) return true;
    return stored.toLowerCase() != 'false';
  }

  static void saveAutoRotate(bool value) {
    html.window.localStorage[_autoRotateKey] = value.toString();
  }

  // 기기의 자동회전 설정을 감지하는 메서드
  static Future<bool> detectDeviceAutoRotateEnabled() async {
    if (!kIsWeb) return true;
    
    try {
      final orientation = html.window.screen?.orientation;
      if (orientation == null) {
        print('Screen Orientation API not supported');
        return true; // API를 지원하지 않으면 기본적으로 허용
      }

      // 더 안전한 방법으로 기기 설정 감지
      // 1. 먼저 현재 상태 확인
      final currentType = orientation.type;
      print('Current orientation: $currentType');

      // 2. MediaQuery를 통한 방향 변경 가능성 확인
      final mediaQuery = html.window.matchMedia('(orientation: portrait)');
      final isPortrait = mediaQuery.matches;
      
      // 3. 간단한 테스트를 통해 기기 설정 확인
      try {
        // 현재 방향과 반대 방향으로 잠그려고 시도
        final testOrientation = isPortrait ? 'landscape-primary' : 'portrait-primary';
        
        // 매우 짧은 시간 동안만 테스트
        await orientation.lock(testOrientation);
        
        // 즉시 해제
        orientation.unlock();
        
        print('Device auto-rotate test successful - rotation allowed');
        return true;
        
      } catch (e) {
        final errorMsg = e.toString().toLowerCase();
        
        // 특정 오류 메시지들을 분석하여 기기 설정 파악
        if (errorMsg.contains('not allowed') || 
            errorMsg.contains('denied') || 
            errorMsg.contains('permission') ||
            errorMsg.contains('locked')) {
          print('Device auto-rotate disabled: $e');
          return false;
        } else if (errorMsg.contains('fullscreen')) {
          print('Fullscreen required for orientation lock');
          // 풀스크린이 필요한 경우는 기기 설정과 무관하므로 허용
          return true;
        } else {
          print('Orientation test failed with unknown error: $e');
          // 알 수 없는 오류는 기본적으로 허용
          return true;
        }
      }
      
    } catch (e) {
      print('Failed to detect device auto-rotate setting: $e');
      return true; // 감지 실패 시 기본적으로 허용
    }
  }

  // 기기 설정을 확인하고 그에 따라 자동회전을 적용
  static Future<void> applyAutoRotateBasedOnDevice() async {
    if (!kIsWeb) return;
    
    final followDeviceSetting = loadFollowDeviceSetting();
    
    if (followDeviceSetting) {
      print('Following device auto-rotate setting...');
      // 기기 설정을 따르는 경우
      final deviceAutoRotateEnabled = await detectDeviceAutoRotateEnabled();
      print('Device auto-rotate enabled: $deviceAutoRotateEnabled');
      
      if (deviceAutoRotateEnabled) {
        // 기기에서 자동회전이 허용된 경우, 웹앱도 자유롭게 회전 허용
        try {
          final orientation = html.window.screen?.orientation;
          orientation?.unlock();
          print('Web app orientation unlocked');
        } catch (e) {
          print('Failed to unlock orientation: $e');
        }
      } else {
        // 기기에서 자동회전이 비활성화된 경우, 현재 방향으로 고정
        try {
          final orientation = html.window.screen?.orientation;
          final currentType = orientation?.type;
          
          if (currentType != null) {
            // 현재 방향으로 고정 (portrait 또는 landscape)
            final lockOrientation = currentType.contains('portrait') ? 'portrait' : 'landscape';
            await orientation?.lock(lockOrientation);
            print('Web app orientation locked to: $lockOrientation');
          }
        } catch (e) {
          print('Failed to lock orientation: $e');
        }
      }
    } else {
      print('Using app-specific auto-rotate setting...');
      // 앱 자체 설정을 사용하는 경우
      final appAutoRotate = loadAutoRotate();
      await applyAutoRotate(appAutoRotate);
    }
  }

  static Future<void> applyAutoRotate(bool value) async {
    if (!kIsWeb) return;
    
    try {
      final orientation = html.window.screen?.orientation;
      if (orientation == null) {
        print('Screen Orientation API not supported');
        return;
      }

      if (value) {
        // 자동회전 허용
        orientation.unlock();
      } else {
        // 세로 모드로 고정
        // lock() 메서드는 Promise를 반환하므로 await 사용
        await orientation.lock('portrait');
      }
    } catch (e) {
      print('Orientation lock failed: $e');
      // 풀스크린이 필요한 경우를 위한 fallback
      if (!value && e.toString().contains('fullscreen')) {
        print('Fullscreen required for orientation lock');
        // 필요시 풀스크린 요청 로직 추가 가능
      }
    }
  }

  // 기기의 자동회전 설정 변경을 감지하는 리스너
  static void startDeviceOrientationListener() {
    if (!kIsWeb) return;
    
    // orientation change 이벤트 리스너
    html.window.addEventListener('orientationchange', (event) async {
      final followDeviceSetting = loadFollowDeviceSetting();
      if (followDeviceSetting) {
        // 기기 설정을 따르는 경우, 변경사항 감지 후 재적용
        await Future.delayed(Duration(milliseconds: 500)); // 방향 변경 완료 대기
        await applyAutoRotateBasedOnDevice();
      }
    });

    // resize 이벤트로도 감지 (일부 브라우저에서 orientationchange가 제대로 동작하지 않을 수 있음)
    html.window.addEventListener('resize', (event) async {
      final followDeviceSetting = loadFollowDeviceSetting();
      if (followDeviceSetting) {
        await Future.delayed(Duration(milliseconds: 300)); // debounce
        await applyAutoRotateBasedOnDevice();
      }
    });
  }

  static Future<bool> requestFullscreen() async {
    if (!kIsWeb) return false;
    
    try {
      await html.document.documentElement?.requestFullscreen();
      return true;
    } catch (e) {
      print('Fullscreen request failed: $e');
      return false;
    }
  }

  static void exitFullscreen() {
    if (!kIsWeb) return;
    
    try {
      html.document.exitFullscreen();
    } catch (e) {
      print('Exit fullscreen failed: $e');
    }
  }

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
