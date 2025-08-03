import 'package:flutter/material.dart';
import '../../../theme/dialog_theme.dart';

/// 앱 전체에서 사용할 기본 다이얼로그 위젯
/// 일관된 스타일링과 접근성을 제공
class AppDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? titleIcon;
  final Color? titleIconColor;
  final bool barrierDismissible;
  final String? semanticLabel;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment actionsAlignment;

  const AppDialog({
    Key? key,
    this.title,
    required this.content,
    this.actions,
    this.titleIcon,
    this.titleIconColor,
    this.barrierDismissible = true,
    this.semanticLabel,
    this.maxWidth,
    this.maxHeight,
    this.contentPadding,
    this.actionsPadding,
    this.actionsAlignment = MainAxisAlignment.end,
  }) : super(key: key);

  /// 간단한 확인 다이얼로그를 위한 팩토리 생성자
  factory AppDialog.confirmation({
    Key? key,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDangerous = false,
    IconData? icon,
  }) {
    return AppDialog(
      key: key,
      title: title,
      titleIcon: icon,
      titleIconColor: isDangerous ? AppDialogTheme.errorColor : AppDialogTheme.primaryColor,
      content: Text(
        message,
        style: AppDialogTheme.bodyTextStyle,
      ),
      actions: [
        OutlinedButton(
          style: AppDialogTheme.secondaryButtonStyle,
          onPressed: onCancel ?? () {},
          child: Text(cancelText),
        ),
        const SizedBox(width: AppDialogTheme.smallSpacing),
        ElevatedButton(
          style: isDangerous 
              ? AppDialogTheme.dangerButtonStyle 
              : AppDialogTheme.primaryButtonStyle,
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
      barrierDismissible: false,
      semanticLabel: '$title 확인 대화상자',
    );
  }

  /// 정보 다이얼로그를 위한 팩토리 생성자
  factory AppDialog.info({
    Key? key,
    required String title,
    required String message,
    VoidCallback? onOk,
    String okText = '확인',
    IconData? icon,
  }) {
    return AppDialog(
      key: key,
      title: title,
      titleIcon: icon ?? Icons.info,
      titleIconColor: AppDialogTheme.primaryColor,
      content: Text(
        message,
        style: AppDialogTheme.bodyTextStyle,
      ),
      actions: [
        ElevatedButton(
          style: AppDialogTheme.primaryButtonStyle,
          onPressed: onOk ?? () {},
          child: Text(okText),
        ),
      ],
      semanticLabel: '$title 정보 대화상자',
    );
  }

  /// 오류 다이얼로그를 위한 팩토리 생성자
  factory AppDialog.error({
    Key? key,
    String title = '오류',
    required String message,
    VoidCallback? onOk,
    String okText = '확인',
  }) {
    return AppDialog(
      key: key,
      title: title,
      titleIcon: Icons.error,
      titleIconColor: AppDialogTheme.errorColor,
      content: Text(
        message,
        style: AppDialogTheme.bodyTextStyle,
      ),
      actions: [
        ElevatedButton(
          style: AppDialogTheme.dangerButtonStyle,
          onPressed: onOk ?? () {},
          child: Text(okText),
        ),
      ],
      semanticLabel: '$title 오류 대화상자',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '대화상자',
      child: AlertDialog(
        shape: AppDialogTheme.dialogShape,
        backgroundColor: AppDialogTheme.backgroundColor,
        title: title != null ? _buildTitle() : null,
        content: _buildContent(context),
        actions: actions,
        contentPadding: contentPadding ?? const EdgeInsets.all(AppDialogTheme.contentPadding),
        actionsPadding: actionsPadding ?? const EdgeInsets.all(AppDialogTheme.actionsPadding),
        actionsAlignment: actionsAlignment,
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        if (titleIcon != null) ...[
          Icon(
            titleIcon,
            color: titleIconColor ?? AppDialogTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: AppDialogTheme.smallSpacing),
        ],
        Expanded(
          child: Text(
            title!,
            style: AppDialogTheme.titleTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? AppDialogTheme.getDialogWidth(context),
        maxHeight: maxHeight ?? AppDialogTheme.maxDialogHeight * 0.7,
      ),
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<T?> show<T>(
    BuildContext context,
    AppDialog dialog, {
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }
} 