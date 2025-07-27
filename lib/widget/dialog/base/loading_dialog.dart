import 'package:flutter/material.dart';
import '../../../theme/dialog_theme.dart';

/// 로딩 상태를 표시하는 다이얼로그
class LoadingDialog extends StatelessWidget {
  final String message;
  final bool canCancel;
  final VoidCallback? onCancel;

  const LoadingDialog({
    Key? key,
    required this.message,
    this.canCancel = false,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canCancel,
      child: AlertDialog(
        shape: AppDialogTheme.dialogShape,
        backgroundColor: AppDialogTheme.backgroundColor,
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppDialogTheme.getDialogWidth(context) * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDialogTheme.spacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 3,
                ),
                const SizedBox(height: AppDialogTheme.spacing),
                Text(
                  message,
                  style: AppDialogTheme.bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
                if (canCancel && onCancel != null) ...[
                  const SizedBox(height: AppDialogTheme.spacing),
                  OutlinedButton(
                    style: AppDialogTheme.secondaryButtonStyle,
                    onPressed: onCancel,
                    child: const Text('취소'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로딩 다이얼로그를 표시하고 작업을 실행하는 정적 메서드
  static Future<T?> execute<T>(
    BuildContext context, {
    required String message,
    required Future<T> Function() task,
    bool canCancel = false,
  }) async {
    bool isCompleted = false;
    T? result;
    
    // 로딩 다이얼로그 표시
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => LoadingDialog(
        message: message,
        canCancel: canCancel,
        onCancel: canCancel ? () {
          if (!isCompleted) {
            Navigator.of(context).pop();
          }
        } : null,
      ),
    );

    try {
      // 작업 실행
      result = await task();
      isCompleted = true;
      
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      return result;
    } catch (e) {
      isCompleted = true;
      
      // 오류 발생 시 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      rethrow;
    }
  }

  /// 간단한 로딩 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required String message,
    bool canCancel = false,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => LoadingDialog(
        message: message,
        canCancel: canCancel,
        onCancel: onCancel,
      ),
    );
  }

  /// 로딩 다이얼로그 닫기
  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
} 