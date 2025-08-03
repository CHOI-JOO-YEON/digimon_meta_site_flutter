import 'package:flutter/material.dart';
import '../theme/dialog_theme.dart';
import '../widget/common/toast_overlay.dart';

/// 앱 전체에서 사용할 공통 다이얼로그 서비스
class DialogService {
  DialogService._();
  static final DialogService _instance = DialogService._();
  static DialogService get instance => _instance;

  /// 확인 다이얼로그 표시
  /// [title] 다이얼로그 제목
  /// [message] 표시할 메시지
  /// [confirmText] 확인 버튼 텍스트 (기본값: '확인')
  /// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
  /// [isDangerous] 위험한 작업인지 여부 (기본값: false)
  /// 반환값: 사용자가 확인을 누르면 true, 취소하거나 다이얼로그를 닫으면 false
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: AppDialogTheme.dialogShape,
          title: Text(
            title,
            style: AppDialogTheme.titleTextStyle,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppDialogTheme.getDialogWidth(context),
            ),
            child: Text(
              message,
              style: AppDialogTheme.bodyTextStyle,
            ),
          ),
          actions: [
            OutlinedButton(
              style: AppDialogTheme.secondaryButtonStyle,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            const SizedBox(width: AppDialogTheme.smallSpacing),
            ElevatedButton(
              style: isDangerous 
                  ? AppDialogTheme.dangerButtonStyle 
                  : AppDialogTheme.primaryButtonStyle,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  /// 정보 다이얼로그 표시
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
    IconData? icon,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: AppDialogTheme.dialogShape,
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppDialogTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppDialogTheme.smallSpacing),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppDialogTheme.titleTextStyle,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppDialogTheme.getDialogWidth(context),
            ),
            child: Text(
              message,
              style: AppDialogTheme.bodyTextStyle,
            ),
          ),
          actions: [
            ElevatedButton(
              style: AppDialogTheme.primaryButtonStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// 로딩 다이얼로그 표시
  static Future<T?> showLoading<T>(
    BuildContext context, {
    required String message,
    required Future<T> Function() task,
  }) async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: AppDialogTheme.dialogShape,
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppDialogTheme.getDialogWidth(context),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDialogTheme.spacing),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: AppDialogTheme.spacing),
                    Expanded(
                      child: Text(
                        message,
                        style: AppDialogTheme.bodyTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      // 작업 실행
      final result = await task();
      
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      return result;
    } catch (e) {
      // 오류 발생 시 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  /// 선택 다이얼로그 표시
  static Future<T?> showSelection<T>(
    BuildContext context, {
    required String title,
    required List<DialogOption<T>> options,
    String? message,
    IconData? icon,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: AppDialogTheme.dialogShape,
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppDialogTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppDialogTheme.smallSpacing),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppDialogTheme.titleTextStyle,
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppDialogTheme.getDialogWidth(context),
              maxHeight: AppDialogTheme.maxDialogHeight * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message != null) ...[
                    Text(
                      message,
                      style: AppDialogTheme.bodyTextStyle,
                    ),
                    const SizedBox(height: AppDialogTheme.spacing),
                  ],
                  ...options.map((option) => 
                    ListTile(
                      leading: option.icon != null 
                          ? Icon(option.icon, color: AppDialogTheme.primaryColor)
                          : null,
                      title: Text(
                        option.title,
                        style: AppDialogTheme.bodyTextStyle,
                      ),
                      subtitle: option.subtitle != null
                          ? Text(
                              option.subtitle!,
                              style: AppDialogTheme.captionTextStyle,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(option.value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              style: AppDialogTheme.secondaryButtonStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  /// 에러 다이얼로그 표시
  static Future<void> showError(
    BuildContext context, {
    required String message,
    String title = '오류',
    String buttonText = '확인',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: AppDialogTheme.dialogShape,
          title: Row(
            children: [
              Icon(
                DialogIcons.error,
                color: AppDialogTheme.errorColor,
                size: 24,
              ),
              const SizedBox(width: AppDialogTheme.smallSpacing),
              Expanded(
                child: Text(
                  title,
                  style: AppDialogTheme.titleTextStyle.copyWith(
                    color: AppDialogTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppDialogTheme.getDialogWidth(context),
            ),
            child: Text(
              message,
              style: AppDialogTheme.bodyTextStyle,
            ),
          ),
          actions: [
            ElevatedButton(
              style: AppDialogTheme.dangerButtonStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// 성공 메시지를 토스트로 표시
  static void showSuccess(BuildContext context, String message) {
    ToastOverlay.show(
      context,
      message,
      type: ToastType.success,
    );
  }

  /// 경고 메시지를 토스트로 표시
  static void showWarning(BuildContext context, String message) {
    ToastOverlay.show(
      context,
      message,
      type: ToastType.warning,
    );
  }

  /// 정보 메시지를 토스트로 표시
  static void showToast(BuildContext context, String message) {
    ToastOverlay.show(
      context,
      message,
      type: ToastType.info,
    );
  }
}

/// 선택 다이얼로그에서 사용할 옵션 클래스
class DialogOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;

  const DialogOption({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
} 