import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

import '../../../model/deck-build.dart';
import '../../../model/limit_dto.dart';
import '../../../model/user_setting_dto.dart';
import '../../../model/sort_criterion_dto.dart';
import '../../../provider/limit_provider.dart';
import '../../../provider/deck_sort_provider.dart';
import '../../../provider/user_provider.dart';
import '../../../service/user_setting_service.dart';
import '../../../service/lang_service.dart';
import '../../../service/size_service.dart';
import '../../../theme/dialog_theme.dart';
import '../../../widget/common/toast_overlay.dart';
import '../base/app_dialog.dart';

/// 덱 설정을 위한 다이얼로그
class DeckSettingDialog extends StatefulWidget {
  final DeckBuild deck;
  final VoidCallback onSettingsChanged;

  const DeckSettingDialog({
    Key? key,
    required this.deck,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<DeckSettingDialog> createState() => _DeckSettingDialogState();

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required DeckBuild deck,
    required VoidCallback onSettingsChanged,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DeckSettingDialog(
        deck: deck,
        onSettingsChanged: onSettingsChanged,
      ),
    );
  }
}

class _DeckSettingDialogState extends State<DeckSettingDialog> {
  late LimitDto? selectedLimit;
  late bool isStrict;
  late List<SortCriterion> sortPriority;
  late List<String> localePriority;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    final limitProvider = Provider.of<LimitProvider>(context, listen: false);
    final deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);

    // selectedLimit 초기화
    selectedLimit = limitProvider.selectedLimit;
    
    // 로컬 스토리지에서 defaultLimitId 확인
    final defaultLimitIdStr = html.window.localStorage['defaultLimitId'];
    final defaultLimitId = defaultLimitIdStr != null ? int.tryParse(defaultLimitIdStr) : null;
    
    if (defaultLimitId == null || defaultLimitId == 0) {
      selectedLimit = LimitDto(
        id: 0,
        restrictionBeginDate: DateTime.now(),
        allowedQuantityMap: {},
        limitPairs: [],
      );
    }
    
    isStrict = widget.deck.isStrict;
    
    sortPriority = List.from(
      deckSortProvider.sortPriority.map(
        (criterion) => SortCriterion(
          criterion.field,
          ascending: criterion.ascending,
          orderMap: criterion.orderMap != null
              ? Map<String, int>.from(criterion.orderMap!)
              : null,
        ),
      ),
    );
    
    // 로컬 스토리지에서 locale 우선순위 로드
    final localePriorityStr = html.window.localStorage['localePriority'];
    
    localePriority = localePriorityStr != null 
        ? localePriorityStr.split(',').where((s) => s.isNotEmpty).toList()
        : ['KOR', 'ENG', 'JPN'];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LimitProvider, DeckSortProvider, UserProvider>(
      builder: (context, limitProvider, deckSortProvider, userProvider, child) {
        return AppDialog(
          title: '덱 설정',
          titleIcon: Icons.settings,
          maxWidth: AppDialogTheme.getDialogWidth(context),
          maxHeight: AppDialogTheme.getDialogHeight(context),
          content: _buildContent(context, limitProvider, deckSortProvider),
          actions: _buildActions(context, limitProvider, deckSortProvider, userProvider),
          semanticLabel: '덱 설정 대화상자',
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LimitProvider limitProvider, DeckSortProvider deckSortProvider) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLimitSection(limitProvider),
          const Divider(height: AppDialogTheme.spacing * 2),
          _buildStrictModeSection(),
          const Divider(height: AppDialogTheme.spacing * 2),
          _buildLocalePrioritySection(),
          const Divider(height: AppDialogTheme.spacing * 2),
          _buildSortPrioritySection(deckSortProvider),
        ],
      ),
    );
  }

  Widget _buildLimitSection(LimitProvider limitProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '금지/제한 설정',
          style: AppDialogTheme.titleTextStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppDialogTheme.smallSpacing),
        _buildLimitDropdown(limitProvider),
      ],
    );
  }

  Widget _buildLimitDropdown(LimitProvider limitProvider) {
    return DropdownButtonFormField<LimitDto>(
      value: selectedLimit?.id == 0 ? null : selectedLimit,
      hint: selectedLimit?.id == 0 
          ? Text(
              '항상 최신 금제로 설정',
              style: AppDialogTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: AppDialogTheme.primaryColor,
              ),
            )
          : Text(
              '금지/제한 선택',
              style: AppDialogTheme.bodyTextStyle,
            ),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
      onChanged: (newValue) {
        setState(() {
          selectedLimit = newValue;
          if (newValue != null && newValue.id == 0) {
            selectedLimit = LimitDto(
              id: 0,
              restrictionBeginDate: DateTime.now(),
              allowedQuantityMap: {},
              limitPairs: [],
            );
          }
        });
      },
      items: [
        // 최신 금제 옵션
        DropdownMenuItem<LimitDto>(
          value: LimitDto(
            id: 0,
            restrictionBeginDate: DateTime.now(),
            allowedQuantityMap: {},
            limitPairs: [],
          ),
          child: Text(
            '항상 최신 금제로 설정${limitProvider.limits.isNotEmpty ? ' (현재: ${DateFormat('yyyy-MM-dd').format(limitProvider.limits.values.reduce((a, b) => a.restrictionBeginDate.isAfter(b.restrictionBeginDate) ? a : b).restrictionBeginDate)})' : ''}',
            style: AppDialogTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: AppDialogTheme.primaryColor,
            ),
          ),
        ),
        // 기존 금제 목록
        ...limitProvider.limits.values.map((limitDto) {
          return DropdownMenuItem<LimitDto>(
            value: limitDto,
            child: Text(
              DateFormat('yyyy-MM-dd').format(limitDto.restrictionBeginDate),
              style: AppDialogTheme.bodyTextStyle,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStrictModeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '엄격한 덱 작성 모드',
          style: AppDialogTheme.bodyTextStyle,
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isStrict,
            onChanged: (bool value) {
              setState(() {
                isStrict = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocalePrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '언어 우선순위',
              style: AppDialogTheme.titleTextStyle.copyWith(fontSize: 18),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  localePriority = ['KOR', 'ENG', 'JPN'];
                });
              },
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: '초기화',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppDialogTheme.smallSpacing),
        _buildCompactLocalePriorityList(),
      ],
    );
  }

  Widget _buildCompactLocalePriorityList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          for (int i = 0; i < localePriority.length; i++) ...[
            if (i > 0) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            _buildLocaleChip(localePriority[i], i),
          ],
        ],
      ),
    );
  }

  Widget _buildLocaleChip(String locale, int index) {
    return Draggable<String>(
      data: locale,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getLocaleDisplayName(locale),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade200,
        ),
        child: Text(
          _getLocaleDisplayName(locale),
          style: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: DragTarget<String>(
        onWillAccept: (data) => data != locale,
        onAccept: (draggedLocale) {
          setState(() {
            final draggedIndex = localePriority.indexOf(draggedLocale);
            localePriority.removeAt(draggedIndex);
            localePriority.insert(index, draggedLocale);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty 
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
              border: candidateData.isNotEmpty
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLocaleDisplayName(locale),
                  style: TextStyle(
                    color: candidateData.isNotEmpty 
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty 
                      ? Theme.of(context).primaryColor
                      : Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: candidateData.isNotEmpty 
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getLocaleDisplayName(String locale) {
    switch (locale) {
      case 'KOR':
        return '한국어';
      case 'JPN':
        return '일본어';
      case 'ENG':
        return '영어';
      default:
        return locale;
    }
  }

  Widget _buildSortPrioritySection(DeckSortProvider deckSortProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '정렬 우선순위',
              style: AppDialogTheme.titleTextStyle.copyWith(fontSize: 18),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  sortPriority = deckSortProvider.getOriginalSortPriority();
                });
              },
              icon: const Icon(Icons.refresh),
              tooltip: '초기화',
            ),
          ],
        ),
        const SizedBox(height: AppDialogTheme.smallSpacing),
        _buildSortPriorityList(),
      ],
    );
  }

  Widget _buildSortPriorityList() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        itemCount: sortPriority.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final SortCriterion item = sortPriority.removeAt(oldIndex);
            sortPriority.insert(newIndex, item);
          });
        },
        itemBuilder: (BuildContext context, int index) {
          final criterion = sortPriority[index];
          return _buildSortCriterionTile(criterion, index);
        },
      ),
    );
  }

  Widget _buildSortCriterionTile(SortCriterion criterion, int index) {
    final deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
    
    return ListTile(
      key: ValueKey('${criterion.field}-$index'),
      title: Text(
        deckSortProvider.getSortPriorityKor(criterion.field),
        style: AppDialogTheme.bodyTextStyle,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (criterion.field == 'cardType' ||
              criterion.field == 'color1' ||
              criterion.field == 'color2')
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.edit),
              onPressed: () => _showOrderMapDialog(criterion),
            ),
          IconButton(
            tooltip: '오름차순/내림차순',
            icon: (criterion.ascending ?? true)
                ? const Icon(Icons.arrow_drop_up)
                : const Icon(Icons.arrow_drop_down),
            onPressed: () {
              setState(() {
                criterion.ascending = !(criterion.ascending ?? true);
              });
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, LimitProvider limitProvider, 
      DeckSortProvider deckSortProvider, UserProvider userProvider) {
    return [
      OutlinedButton(
        style: AppDialogTheme.secondaryButtonStyle,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('취소'),
      ),
      const SizedBox(width: AppDialogTheme.smallSpacing),
      ElevatedButton(
        style: AppDialogTheme.primaryButtonStyle,
        onPressed: () => _handleSaveSettings(context, limitProvider, deckSortProvider, userProvider),
        child: const Text('확인'),
      ),
    ];
  }

  Future<void> _handleSaveSettings(BuildContext context, LimitProvider limitProvider,
      DeckSortProvider deckSortProvider, UserProvider userProvider) async {
    if (!widget.deck.isStrict && isStrict) {
      // 엄격한 덱 작성 모드 활성화 시 확인 다이얼로그
      final confirmed = await _showStrictModeConfirmation(context);
      if (!confirmed) return;
    }

    // 설정 저장
    await _saveUserSettings(context, userProvider);
    
    // 프로바이더 업데이트
    if (selectedLimit != null) {
      limitProvider.updateSelectLimit(selectedLimit!.restrictionBeginDate);
    }
    widget.deck.updateIsStrict(isStrict);
    deckSortProvider.setSortPriority(sortPriority);
    
    // 콜백 호출
    widget.onSettingsChanged();
    
    Navigator.of(context).pop();
  }

  Future<bool> _showStrictModeConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppDialog.confirmation(
        title: '경고',
        message: '엄격한 덱 작성 모드를 활성화하시겠습니까?\n지금까지 작성된 내용은 사라집니다.',
        confirmText: '확인',
        cancelText: '취소',
        isDangerous: true,
        icon: Icons.warning,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    ) ?? false;
  }

  Future<void> _saveUserSettings(BuildContext context, UserProvider userProvider) async {
    final setting = UserSettingDto(
      localePriority: localePriority,
      defaultLimitId: selectedLimit?.id == 0 ? 0 : selectedLimit?.id,
      strictDeck: isStrict,
      sortPriority: sortPriority.map((criterion) => 
        SortCriterionDto(
          field: criterion.field,
          ascending: criterion.ascending,
          orderMap: criterion.orderMap,
        )
      ).toList(),
    );

    // 설정을 즉시 적용
    await UserSettingService().applyUserSetting(context, setting);

    // 서버에 설정 저장 (로그인된 경우)
    if (userProvider.isLogin) {
      final saveSuccess = await UserSettingService().saveUserSetting(context, setting);
      if (saveSuccess) {
        ToastOverlay.show(
          context,
          '설정이 서버에 저장되었습니다.',
          type: ToastType.success
        );
      } else {
        ToastOverlay.show(
          context,
          '서버 저장에 실패했습니다. 브라우저에만 저장됩니다.',
          type: ToastType.warning
        );
      }
    } else {
      await UserSettingService().saveUserSetting(context, setting);
      ToastOverlay.show(
        context,
        '설정이 브라우저에 저장되었습니다.',
        type: ToastType.info
      );
    }
  }

  void _showOrderMapDialog(SortCriterion criterion) {
    final deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
    List<String> items = criterion.orderMap!.keys.toList();
    
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AppDialog(
          title: '${deckSortProvider.getSortPriorityKor(criterion.field)} 순서 변경',
          titleIcon: Icons.reorder,
          content: SizedBox(
            width: AppDialogTheme.getDialogWidth(context) * 0.8,
            height: 300,
            child: ReorderableListView(
              shrinkWrap: true,
              onReorder: (int oldIndex, int newIndex) {
                setDialogState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final String item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);
                });
              },
              children: [
                for (int index = 0; index < items.length; index++)
                  ListTile(
                    key: ValueKey(items[index]),
                    title: Text(
                      LangService().getKorText(items[index]),
                      style: AppDialogTheme.bodyTextStyle,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              style: AppDialogTheme.secondaryButtonStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            const SizedBox(width: AppDialogTheme.smallSpacing),
            ElevatedButton(
              style: AppDialogTheme.primaryButtonStyle,
              onPressed: () {
                setState(() {
                  criterion.orderMap = {
                    for (int i = 0; i < items.length; i++) items[i]: i + 1
                  };
                });
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
} 